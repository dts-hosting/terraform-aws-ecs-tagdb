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
                        logger.info(data)
                except Exception as e:
                    logger.error(cluster, arn, e)

    for data in batch:
        # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html#Streams.Processing
        # PutItem with no changes does not trigger a stream update
        response = table.put_item(
            Item=data
        )
        logger.info(response)
