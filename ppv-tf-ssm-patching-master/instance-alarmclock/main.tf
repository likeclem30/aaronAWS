variable "lambda_policy_name" { }
variable "lambda_role_name" { }
variable "lambda_function_name" { }
variable "lambda_env_var_environment_values" { }

terraform {
  backend "s3" {
    encrypt = true
    bucket = "ndm-ppv-npn-terraform-trss"
    region = "us-east-1"
    key = "start_instances.tfstate"
  }
}

provider "aws" {
  region     = "us-east-1"
}

module "main" {
  source = "./modules"

  lambda_policy_name = "${var.lambda_policy_name}"
  lambda_role_name = "${var.lambda_role_name}"
  lambda_function_name = "${var.lambda_function_name}"
  lambda_env_var_environment_values = "${var.lambda_env_var_environment_values}"
}