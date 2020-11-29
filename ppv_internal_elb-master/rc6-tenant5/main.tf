provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "ndm-ppv-npn-tfstate"
    region = "us-east-1"
    key = "tfstate-dir/ppv-rc6-tenant5/ppv-rc6-tenant5-es-elb.tfstate"
    }
}