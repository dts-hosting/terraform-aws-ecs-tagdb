variable "tagdb_env" {
  default     = "production"
  description = "TagDB env indicator"
}

variable "tagdb_key_tag" {
  default     = "ServiceId"
  description = "ECS service tag that matches the DynamoDB table primary key"
}

variable "tagdb_schedule" {
  default     = "cron(0 0 * * ? *)"
  description = "Schedule for Lambda execution"
}

variable "tagdb_table" {
  default     = "tagdb"
  description = "TagDB table name"
}

variable "tagdb_table_indexes" {
  default     = []
  description = "TagDB table global secondary indexes"
}

variable "tagdb_table_read_capacity" {
  default     = 1
  description = "TagDB table read capacity"
}

variable "tagdb_table_stream_view_type" {
  default     = "NEW_IMAGE"
  description = "TagDB table stream view type"
}

variable "tagdb_table_write_capacity" {
  default     = 1
  description = "TagDB table write capacity"
}
