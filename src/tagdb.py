"""TagDB Lambda function for processing ECS service tags and updating a DynamoDB table."""

import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

if os.environ.get('TAGDB_ENV', 'test') == 'test':
    logger.info('Running with DynamoDB local')
    ddb_client = boto3.resource(
        'dynamodb', endpoint_url='http://dynamodb-local:8000')
else:
    ddb_client = boto3.resource('dynamodb')


ecs_client = boto3.client('ecs')


def handler(event, _context):
    """
    Lambda function handler for processing ECS service tags and updating a DynamoDB table.

    Args:
        event (dict): The event data passed to the Lambda function.
        _context (object): The context object passed to the Lambda function.

    Returns:
        dict: The response from the DynamoDB update operation.
    """
    key_tag = os.environ.get('TAGDB_KEY_TAG', 'ServiceId')
    table = ddb_client.Table(os.environ.get('TAGDB_TABLE', 'tagdb'))
    service_arn = event["resources"][0]

    response = ecs_client.list_tags_for_resource(
        resourceArn=service_arn
    )

    data = {}
    for tag in response.get('tags'):
        data[tag.get('key')] = tag.get('value')

    if key_tag not in data:
        return

    response = update(table, key_tag, data)
    logger.info(response)
    return response


def update(table, key_tag, item):
    """
    Updates an item in the specified DynamoDB table.

    Args:
        table (boto3.resources.factory.dynamodb.Table): The DynamoDB table to update.
        key_tag (str): The key tag used to identify the item to update.
        item (dict): The item to create/update in DynamoDB.

    Returns:
        dict: The updated item.

    Raises:
        botocore.exceptions.ClientError: If the update operation fails.
    """
    logger.info(item)
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
