import json
import os
import boto3
from botocore.exceptions import ClientError

# ロガーの設定
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# DynamoDBテーブル名を環境変数から取得
group_table_name = os.environ.get('GROUP_TABLE_NAME')

# DynamoDBへのクライアントを設定
dynamodb = boto3.resource('dynamodb')
group_table = dynamodb.Table(group_table_name)

def lambda_handler(event, context):
    # イベントの内容をログに記録
    logger.info(f"Received event: {json.dumps(event)}")

    if event['triggerSource'] == "PreSignUp_SignUp":
        user_attributes = event['request']['userAttributes']
        
        # 所属ユーザーの場合、groupIDをチェック
        if 'custom:InvitedGroupID' in user_attributes:
            group_id = user_attributes['custom:InvitedGroupID']
            logger.info(f"Checking groupID: {group_id}")

            try:
                response = group_table.get_item(Key={'id': group_id})
                if 'Item' not in response:
                    logger.warning(f"No group found with groupID: {group_id}")
                    raise Exception("GroupID does not exist")

                # ユーザーを自動的に確認済みとして扱う
                event['response']['autoConfirmUser'] = True
                logger.info("User auto confirmed for the group member")
            except ClientError as e:
                logger.error(f"Failed to query group table: {e.response['Error']['Message']}")
                raise e

    return event
