# Terraform AWS ECS TagDB

Provides a Lambda and DynamoDB table for importing ECS service tags. The
table can then be used for other integrations more easily than having to
go through the ECS service tags directly.

## Usage

```hcl
module "tagdb" {
  source = "github.com/dts-hosting/terraform-aws-ecs-tagdb//modules/tagdb"

  # defaults
  tagdb_env                    = "production"
  tagdb_key_tag                = "ServiceId"
  tagdb_table                  = "tagdb"
  tagdb_table_read_capacity    = 1
  tagdb_table_stream_view_type = "NEW_IMAGE"
  tagdb_table_write_capacity   = 1
  tagdb_table_indexes          = []
}
```

## Local testing

[AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) is required for local development and testing.

```bash
make install

# start DynamoDB locally & create the tagdb table
make setup

# import data to local table
make import service=$profile
```

The `profile` must be a valid AWS profile and the payload is expected at
`./events/$profile.json`:

```json
{
  "version": "0",
  "id": "ddca6449-b258-46c0-8653-e0e3aEXAMPLE",
  "detail-type": "ECS Deployment State Change",
  "source": "aws.ecs",
  "account": "111122223333",
  "time": "2020-05-23T12:31:14Z",
  "region": "us-west-2",
  "resources": [
    "INSERT_ECS_SERVICE_ARN_HERE"
  ],
  "detail": {
    "eventType": "INFO",
    "eventName": "SERVICE_DEPLOYMENT_COMPLETED",
    "deploymentId": "ecs-svc/123",
    "updatedAt": "2020-05-23T11:11:11Z",
    "reason": "ECS deployment deploymentID completed."
  }
}
```

## Viewing data

Run the scan script to see the imported data:

```bash
make scan
```

## Building the lambda package

```bash
make build
```

If anything has changed (requirements or src) the zip file will be updated.
