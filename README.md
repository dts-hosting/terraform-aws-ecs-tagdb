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
  tagdb_schedule               = "cron(0 0 * * ? *)"
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
# start DyanamoDB locally & create the tagdb table
make setup

# import data to local table
AWS_PROFILE=profile make import
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
