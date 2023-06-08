#!/bin/bash
# AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy ./scan.sh
# AWS_PROFILE=dspaceprogramteam ./scan.sh https://dynamodb.us-west-2.amazonaws.com

ENDPOINT_URL=${1:-"http://localhost:8000"}

aws dynamodb scan --table-name tagdb --endpoint-url $ENDPOINT_URL
