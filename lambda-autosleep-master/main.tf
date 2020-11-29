variable "lambda_policy_name" { }
variable "lambda_role_name" { }
variable "s3_rw_policy_name" { }
variable "lambda_function_name" { }
variable "lambda_env_var_tag_values" { }
variable "s3_bucket_name" { }

provider "aws" {
  region     = "us-east-1"
}

module "main" {
  source = "modules/"

  lambda_policy_name = "${var.lambda_policy_name}"
  lambda_role_name = "${var.lambda_role_name}"
  s3_rw_policy_name = "${var.s3_rw_policy_name}"
  lambda_function_name = "${var.lambda_function_name}"
  lambda_env_var_tag_values = "${var.lambda_env_var_tag_values}"
  s3_bucket_name = "${var.s3_bucket_name}"
}
