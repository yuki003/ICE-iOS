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
tasks_table_name = os.environ.get('TASKS_TABLE_NAME')

# DynamoDBへのクライアントを設定
dynamodb = boto3.resource('dynamodb')
group_table = dynamodb.Table(group_table_name)
tasks_table = dynamodb.Table(tasks_table_name)

def handler(event, context):
    # DynamoDB Streamからレコードを取得
    for record in event['Records']:
        logger.info(f"Processing record: {record}")

        if record['eventName'] == 'INSERT':
            new_task = record['dynamodb']['NewImage']
            task_id = new_task['id']['S']
            group_id = new_task['groupID']['S']

            try:
                response = group_table.query(
                    KeyConditionExpression=Key('id').eq(group_id)
                )
                groups = response['Items']
                if not groups:
                    logger.warning(f"No group found with groupID: {group_id}")
                    continue

                group = groups[0]
                if 'taskIDs' not in group:
                    group['taskIDs'] = [task_id]
                else:
                    group['taskIDs'].append(task_id)

                group_table.update_item(
                    Key={'id': group['id']},
                    UpdateExpression='SET taskIDs = :val',
                    ExpressionAttributeValues={
                        ':val': group['taskIDs']
                    }
                )
                logger.info(f"Added taskID {task_id} to group {group['id']}")
            except ClientError as e:
                logger.error(f"Failed to update group {group_id}: {e.response['Error']['Message']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Success!')
    }
