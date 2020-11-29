# AWS SSM and Patch setup
This Terraform script is intended to be used for patching AWS instances using SSM

## Updating the Environment
To be able to run the terraform scripts you will need to specify first the S3 backend to be used in the `main.tf` file.

```terraform
terraform {
  backend "s3" {
    bucket = "ndm-ppv-npn-terraform-trss" # Found in the S3 of each account
    key = "ppv-npn-ssm-patching.tfstate" # Found inside the bucket
    region = "us-east-1"
    encrypt = true
  }
}
```

The command to execute the terraform script is:
```sh
aws vault ndm-ppv -- terraform apply --var-file=./envs/<envfile>
```

## Documentation
Useful links
- https://support.microsoft.com/en-us/help/824684/description-of-the-standard-terminology-that-is-used-to-describe-micro
- How Patch Manager works: https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-how-it-works-installation.html
- Ubuntu cleanup procedure: https://aws.amazon.com/premiumsupport/knowledge-center/resolve-inspector-notifications/