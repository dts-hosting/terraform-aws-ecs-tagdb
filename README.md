# Terraform AWS ECS TagDB

Provides a Lambda and DynamoDB table for importing ECS service tags. The
table can then be used for other integrations more easily than having to
go through the ECS service tags directly.

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
sudo chown $USER -R docker
AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy ./create_db.sh
```

Run the tagdb function handler to read tags from ECS and import data:

```bash
# import into ddb local
pip install python-lambda-local
AWS_PROFILE=myprofile make import

# if the table is deployed in AWS you can import directly
AWS_PROFILE=myprofile TAGDB_ENV=production make import
```

Run the scan script to see the imported data:

```bash
AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy ./scan.sh
```

Environment variables:

- TAGDB_ENV (default: `test`)
- TAGDB_KEY_TAG (default: `ServiceId`)
- TAGDB_TABLE (default: `tagdb`)

## Building the lambda package

```bash
make build
```

If anything has changed (requirements or src) the zip file will be updated.
