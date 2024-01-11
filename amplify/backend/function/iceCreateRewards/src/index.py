import json
import os
import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError

# ロガーの設定
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# DynamoDBテーブル名
group_table_name = os.environ.get('GROUP_TABLE_NAME')
rewards_table_name = os.environ.get('REWARDS_TABLE_NAME')

# DynamoDBへのクライアントを設定
dynamodb = boto3.resource('dynamodb')
group_table = dynamodb.Table(group_table_name)
rewards_table = dynamodb.Table(rewards_table_name)

def lambda_handler(event, context):
    # DynamoDB Streamからレコードを取得
    for record in event['Records']:
        logger.info(f"Processing record: {record}")

        if record['eventName'] == 'INSERT':
            new_reward = record['dynamodb']['NewImage']
            reward_id = new_reward['id']['S']
            group_id = new_reward['groupID']['S']

            try:
                response = group_table.query(
                    KeyConditionExpression=Key('id').eq(group_id)
                )
                groups = response['Items']
                if not groups:
                    logger.warning(f"No group found with groupID: {group_id}")
                    continue

                group = groups[0]
                if 'rewardIDs' not in group:
                    group['rewardIDs'] = [reward_id]
                else:
                    group['rewardIDs'].append(reward_id)

                group_table.update_item(
                    Key={'id': group['id']},
                    UpdateExpression='SET rewardIDs = :val',
                    ExpressionAttributeValues={
                        ':val': group['rewardIDs']
                    }
                )
                logger.info(f"Added rewardID {reward_id} to group {group['id']}")
            except ClientError as e:
                logger.error(f"Failed to update group {group_id}: {e.response['Error']['Message']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Success!')
    }
