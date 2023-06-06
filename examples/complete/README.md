# Complete TagDB example

Configuration in this directory creates a DynamoDB table and tagdb function to
import ECS service tags.

## Usage

```bash
terraform init
AWS_PROFILE=default terraform plan
AWS_PROFILE=default terraform apply
```

Note that this example creates resources which cost money. Run terraform destroy
when you don't need these resources.
