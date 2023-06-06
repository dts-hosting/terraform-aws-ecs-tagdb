# Terraform AWS ECS TagDB

Provides a Lambda and DynamoDB table for importing ECS service tags. The
table can then be used for other integrations more easily than having to
go through the ECS service tags.

## Usage

```hcl
module "tagdb" {
  source = "github.com/dts-hosting/terraform-aws-ecs-tagdb"

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

Create the DynamoDB tagdb table and run DynamoDB local using Docker:

```bash
docker compose up -d
AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy ./create_db.sh
```

Run the tagdb function handler:

```bash
pip install python-lambda-local
AWS_PROFILE=dspaceprogramteam make import
```

## Building the lambda package

```bash
make build
```

If anything has changed (requirements or src) the zip file will be updated.
