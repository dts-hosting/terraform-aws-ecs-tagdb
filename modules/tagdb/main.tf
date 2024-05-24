locals {
  handler = "tagdb.handler"
  pkg     = "${path.module}/../../build/terraform-aws-ecs-tagdb.zip"
  project = "terraform-aws-ecs-tagdb"
}

resource "aws_lambda_function" "this" {
  filename         = local.pkg
  function_name    = local.project
  role             = aws_iam_role.this.arn
  handler          = local.handler
  runtime          = "python3.10"
  source_code_hash = filebase64sha256(local.pkg)
  timeout          = 30

  environment {
    variables = {
      TAGDB_ENV     = var.tagdb_env
      TAGDB_KEY_TAG = var.tagdb_key_tag
      TAGDB_TABLE   = var.tagdb_table
    }
  }

  depends_on = [aws_iam_role.this]
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "tagdb-ecs-deployment-completed"
  description = "Fires when an ECS deployment is completed (TagDB)"

  event_pattern = <<PATTERN
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Deployment State Change"],
  "detail": {
    "eventName": ["SERVICE_DEPLOYMENT_COMPLETED"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "this" {
  arn       = aws_lambda_function.this.arn
  rule      = aws_cloudwatch_event_rule.this.id
  target_id = aws_lambda_function.this.function_name
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
