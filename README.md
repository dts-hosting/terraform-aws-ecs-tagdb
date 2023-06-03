# Terraform AWS ECS TagDB

Provides a Lambda for importing ECS service tags into a DynamoDB table.
The table can then be used for other integrations more easily than having
to go through ECS service tags.

## Module config

- `tagdb_env` (default: `test`)
- `tagdb_key_tag` (default: `ServiceId`)
- `tagdb_schedule` (default: `cron(0 0 * * ? *)`)
- `tagdb_table` (default: `tagdb`)

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
