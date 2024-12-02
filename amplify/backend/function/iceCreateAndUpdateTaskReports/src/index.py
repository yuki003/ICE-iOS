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

        if record['eventName'] in ['INSERT', 'MODIFY']:
            new_report = record['dynamodb']['NewImage']
            report_status = new_report['status']['S']
            task_id = new_report['taskID']['S']

            try:
                # タスクIDに対応するタスクを取得
                response = tasks_table.get_item(Key={'id': task_id})
                task = response.get('Item')
                if not task:
                    logger.warning(f"No task found with taskID: {task_id}")
                    continue

                # hasPendingReportの値を更新
                has_pending_report = report_status == 'PENDING'

                tasks_table.update_item(
                    Key={'id': task_id},
                    UpdateExpression='SET hasPendingReport = :val',
                    ExpressionAttributeValues={
                        ':val': has_pending_report
                    }
                )
                logger.info(f"Updated task {task_id} with hasPendingReport={has_pending_report}")
            except ClientError as e:
                logger.error(f"Failed to update task {task_id}: {e.response['Error']['Message']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Success!')
    }
