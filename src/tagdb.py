import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

if os.environ.get('TAGDB_ENV', 'test') == 'test':
    logger.info('Running with DynamoDB local')
    ddb_client = boto3.resource(
        'dynamodb', endpoint_url='http://localhost:8000')
else:
    ddb_client = boto3.resource('dynamodb')

ecs_client = boto3.client('ecs')
ecs_pager = ecs_client.get_paginator('list_services')


def handler(event, context):
    batch = []
    key_tag = os.environ.get('TAGDB_KEY_TAG', 'ServiceId')
    table = ddb_client.Table(os.environ.get('TAGDB_TABLE', 'tagdb'))

    for cluster in ecs_client.list_clusters(maxResults=100).get('clusterArns'):
        for page in ecs_pager.paginate(cluster=cluster, PaginationConfig={'MaxItems': 10}):
            for arn in page.get('serviceArns'):
                try:
                    response = ecs_client.list_tags_for_resource(
                        resourceArn=arn
                    )
                    data = {}
                    for tag in response.get('tags'):
                        data[tag.get('key')] = tag.get('value')

                    if key_tag in data:
                        batch.append(data)
                except Exception as e:
                    logger.error(f"{e}: {arn}")

    for data in batch:
        response = update(table, key_tag, data)
        logger.info(response)


def update(table, key, data):
    logger.info(data)
    item = data.copy() # don't mutate the original data
    target = item.pop(key)
    update_expression = 'SET {}'.format(','.join(f'#{k}=:{k}' for k in item))
    expression_attribute_values = {f':{k}': v for k, v in item.items()}
    expression_attribute_names = {f'#{k}': k for k in item}

    # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html#Streams.Processing
    # PutItem/UpdateItem with no changes does not trigger a stream update
    return table.update_item(
        Key={
            key: target,
        },
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ExpressionAttributeNames=expression_attribute_names,
        ReturnValues='UPDATED_NEW',
    )
