import json
import os
import boto3
from botocore.exceptions import ClientError

# ロガーの設定
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# DynamoDBテーブル名
tasks_table_name = os.environ.get('TASKS_TABLE_NAME')

# DynamoDBへのクライアントを設定
dynamodb = boto3.resource('dynamodb')
tasks_table = dynamodb.Table(tasks_table_name)

def handler(event, context):
    # DynamoDB Streamからレコードを取得
    for record in event['Records']:
        logger.info(f"Processing record: {record}")

        if record['eventName'] == 'MODIFY':
            new_report = record['dynamodb']['NewImage']
            report_status = new_report['status']['S']
            task_id = new_report['taskID']['S']
            report_user_id = new_report['reportUserID']['S']

            if report_status == 'APPROVED':
                try:
                    # タスクIDに対応するタスクを取得
                    response = tasks_table.get_item(Key={'id': task_id})
                    task = response.get('Item')
                    if not task:
                        logger.warning(f"No task found with taskID: {task_id}")
                        continue

                    receiving_user_ids = task.get('receivingUserIDs', [])
                    rejected_user_ids = task.get('rejectedUserIDs', [])
                    completed_user_ids = task.get('completedUserIDs', [])

                    # receivingUserIDsからreportUserIDを削除
                    if report_user_id in receiving_user_ids:
                        receiving_user_ids.remove(report_user_id)

                    # receivingUserIDsからreportUserIDを削除
                    if report_user_id in rejected_user_ids:
                        rejected_user_ids.remove(report_user_id)
                        
                    # completedUserIDsにreportUserIDを追加
                    if report_user_id not in completed_user_ids:
                        completed_user_ids.append(report_user_id)

                    # TASKSテーブルを更新
                    tasks_table.update_item(
                        Key={'id': task_id},
                        UpdateExpression='SET receivingUserIDs = :receiving, completedUserIDs = :completed',
                        ExpressionAttributeValues={
                            ':receiving': receiving_user_ids,
                            ':completed': completed_user_ids
                        }
                    )
                    logger.info(f"Updated task {task_id}: removed {report_user_id} from receivingUserIDs and added to completedUserIDs")
                except ClientError as e:
                    logger.error(f"Failed to update task {task_id}: {e.response['Error']['Message']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Success!')
    }
