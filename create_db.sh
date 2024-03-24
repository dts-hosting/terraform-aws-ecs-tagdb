#!/bin/bash

export AWS_ACCESS_KEY_ID=dummy
export AWS_SECRET_ACCESS_KEY=dummy
ENDPOINT_URL=http://localhost:8000

docker compose stop && docker compose rm -f || true

docker compose up --detach
sleep 1

aws dynamodb create-table --endpoint-url $ENDPOINT_URL \
  --table-name tagdb \
  --key-schema AttributeName=ServiceId,KeyType=HASH \
  --attribute-definitions \
    AttributeName=ServiceId,AttributeType=S \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

aws dynamodb update-table --endpoint-url $ENDPOINT_URL \
  --table-name 'tagdb' \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_IMAGE
