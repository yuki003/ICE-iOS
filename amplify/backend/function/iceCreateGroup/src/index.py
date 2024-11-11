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
# 環境変数からテーブル名を取得
user_table_name = os.environ.get('USER_TABLE_NAME')
group_table_name = os.environ.get('GROUP_TABLE_NAME')
    
# DynamoDBへのクライアントを設定
dynamodb = boto3.resource('dynamodb')
# Groupテーブルの参照を取得
user_table = dynamodb.Table(user_table_name)
group_table = dynamodb.Table(group_table_name)

def handler(event, context):
    # DynamoDB Streamからレコードを取得
    for record in event['Records']:
        logger.info(f"Processing record: {record}")

        # 新しいレコードのみを対象
        if record['eventName'] == 'INSERT':
            new_group = record['dynamodb']['NewImage']
            group_id = new_group['id']['S']
            host_user_ids = new_group.get('hostUserIDs', {}).get('L', [])

            for user_id in host_user_ids:
                user_id_str = user_id['S']
                logger.info(f"Updating hostGroupIDs for user: {user_id_str}")

                try:
                    # Userテーブルからユーザーを検索
                    response = user_table.query(
                        IndexName="userID-index",  # userIDを使用するためのインデックスを指定
                        KeyConditionExpression=Key('userID').eq(user_id_str)
                    )
                    users = response['Items']
                    if not users:
                        logger.warning(f"No user found with userID: {user_id_str}")
                        continue

                    for user in users:
                        # hostGroupIDsリストを更新
                        if 'hostGroupIDs' not in user:
                            user['hostGroupIDs'] = [group_id]
                        else:
                            user['hostGroupIDs'].append(group_id)
                        
                        # Userテーブルを更新
                        user_table.update_item(
                            Key={'id': user['id']},
                            UpdateExpression='SET hostGroupIDs = :val',
                            ExpressionAttributeValues={
                                ':val': user['hostGroupIDs']
                            }
                        )
                        logger.info(f"Added groupID {group_id} to user {user['id']} hostGroupIDs")
                except ClientError as e:
                    logger.error(f"Failed to update user {user_id_str}: {e.response['Error']['Message']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Success!')
    }
