#!/bin/bash
# AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy ./create_db.sh
# AWS_PROFILE=myprofile ./create_db.sh https://dynamodb.us-west-2.amazonaws.com

ENDPOINT_URL=${1:-"http://localhost:8000"}

aws dynamodb create-table --endpoint-url $ENDPOINT_URL \
  --table-name tagdb \
  --key-schema AttributeName=ServiceId,KeyType=HASH \
  --attribute-definitions \
    AttributeName=ServiceId,AttributeType=S \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

aws dynamodb update-table --endpoint-url $ENDPOINT_URL \
  --table-name 'tagdb' \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_IMAGE

# Example: GSI for project specific requirements
aws dynamodb update-table --endpoint-url $ENDPOINT_URL \
  --table-name tagdb \
  --attribute-definitions AttributeName=BuckerImporterId,AttributeType=S \
  --global-secondary-index-updates \
    "[{\"Create\":{\"IndexName\": \"BuckerImporterId-index\",\"KeySchema\":[{\"AttributeName\":\"BuckerImporterId\",\"KeyType\":\"HASH\"}], \
    \"ProvisionedThroughput\": {\"ReadCapacityUnits\": 1, \"WriteCapacityUnits\": 1},\"Projection\":{\"ProjectionType\":\"ALL\"}}}]"
