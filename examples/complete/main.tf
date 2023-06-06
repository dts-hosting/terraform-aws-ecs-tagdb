provider "aws" {
  region = local.region
}

locals {
  name   = "tagdb-ex-${basename(path.cwd)}"
  region = "us-west-2"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/dts-hosting/terraform-aws-ecs-tagdb"
  }
}

module "tagdb" {
  source = "../.."

  tagdb_schedule = "rate(1 minute)"

  tagdb_table_indexes = {
    BucketImporterIndex = {
      hash_key = "BuckerImporterId"
    }
  }
}
