# Modus Devops Demo Bootstrap

This terraform module is used to bootstrap the backend for the `/terraform` project. It uses [trussworks/bootstrap/aws](https://github.com/trussworks/terraform-aws-bootstrap) module to create all the resources needed to enable terraform backend in AWS.

## How to use

```bash
cd bootstrap
terraform init
terraform apply
```

This will generate output which looks like this:

```
backend_details = {
  "dynamodb_table" = "moduscreate-devops-demo-state-lock"
  "logging_bucket" = "moduscreate-devops-demo-tf-state-log-us-east-1"
  "state_bucket" = "moduscreate-devops-demo-tf-state-us-east-1"
}
```

It can then be used in the `terraform.backend` config of main project (not the bootstrap project).

```terraform
terraform {
  # ... existing config

  backend "s3" {
    bucket = "moduscreate-devops-demo-tf-state-us-east-1"
    key = "terraform-state.tfstate"
    dynamodb_table = "moduscreate-devops-demo-state-lock"
    region = "us-east-1"
    encrypt = "true"
  }
}
```

## Inputs

| Name            | Description                  | Default                 |
|-----------------|------------------------------|-------------------------|
| `aws_region`    | Amazon region to use         | us-east-1               |
| `account_alias` | Prefix for backend resources | moduscreate-devops-demo |
