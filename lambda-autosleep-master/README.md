# lambda-autosleep
This function is intended to be used to stop/start instances and/or increase/decrease Autoscaling group size

##Deploying with Terraform
Fill first the values of variables in the main.tfvars.
```
lambda_policy_name: Name of the lambda execution policy
lambda_role_name: Name of the lambda execution role
s3_rw_policy_name: Name of S3 role which has rw to the autosleep bucket
lambda_function_name: Name of the lambda function
lambda_env_var_tag_values: Comma separated string with the name of the tags
s3_bucket_name: Name of the S3 bucket to be used to upload files
```

You can deploy using the commands below:

```bash
terraform init
terraform plan --var-file=main.tfvars
terraform apply --var-file=main.tfvars
```

To keep states on s3 you can add the following lines in the main.tf file.
```terraform
terraform {
  backend "s3" {
    encrypt = true
    bucket = "ndm-ppv-npn-terraform-trss"
    region = "us-east-1"
    key = "autosleep_lambda.tfstate"
    }
}
```

## Usage

For the autosleep function be able to recognize which autoscaling groups and instances need to resize, you will need to specify:
1. Name of the tags in an environment variable as with the key tag.
2. Values as a directory folder on the s3 bucket.
3. Instances and Autoscaling groups need to have this tags and an extra tag: pause_exclude = false .

This values will need to be specified in order for them to be assigned properly.

Example:
```
Env: tenant,solution,component
S3: tenant0/pag/web
```

For autoscaling groups, you will need to specify three more tags:
```
sleep_minSize
sleep_maxSize
sleep_desiredCapacity
```

## Trigger Function
If an empty file (0KB) is uploaded it will stop or decrease the size of the autoscaling group. If file has a bigger size, it will start or scale back the instance.
A policy is created as part of the terraform script with the permissions to add files into the s3 bucket.