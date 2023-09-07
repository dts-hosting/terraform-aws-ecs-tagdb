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
        for page in ecs_pager.paginate(cluster=cluster, PaginationConfig={'MaxItems': 1000}):
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

    keys = get_keys(table, key_tag)
    for data in batch:
        response = update(table, key_tag, data)
        logger.info(response)
        if data[key_tag] in keys:
            keys.remove(data[key_tag])  # remove this entry from keys if found

    # delete items for which there was no matching key (the remaining keys)
    # i.e. there's no longer a corresponding ecs service for this key
    for key in keys:
        response = delete(table, key_tag, key)
        logger.info(response)


def delete(table, key_tag, key):
    return table.delete_item(
        Key={
            key_tag: key
        }
    )


def get_keys(table, key_tag):
    response = table.scan()
    data = response['Items']

    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    return [i[key_tag] for i in data]


def update(table, key_tag, data):
    logger.info(data)
    item = data.copy()  # don't mutate the original data
    target = item.pop(key_tag)
    update_expression = 'SET {}'.format(','.join(f'#{k}=:{k}' for k in item))
    expression_attribute_values = {f':{k}': v for k, v in item.items()}
    expression_attribute_names = {f'#{k}': k for k in item}

    # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html#Streams.Processing
    # PutItem/UpdateItem with no changes does not trigger a stream update
    return table.update_item(
        Key={
            key_tag: target,
        },
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ExpressionAttributeNames=expression_attribute_names,
        ReturnValues='UPDATED_NEW',
    )
