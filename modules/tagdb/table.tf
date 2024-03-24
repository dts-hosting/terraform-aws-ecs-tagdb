resource "aws_dynamodb_table" "this" {
  name             = var.tagdb_table
  billing_mode     = "PROVISIONED"
  read_capacity    = var.tagdb_table_read_capacity
  write_capacity   = var.tagdb_table_write_capacity
  hash_key         = var.tagdb_key_tag
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = var.tagdb_key_tag
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.tagdb_table_indexes
    content {
      name = attribute.value.hash_key
      type = "S"
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.tagdb_table_indexes
    content {
      name               = global_secondary_index.key
      hash_key           = global_secondary_index.value.hash_key
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", 1)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", 1)
      projection_type    = lookup(global_secondary_index.value, "projection_type", "ALL")
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
    }
  }
}
