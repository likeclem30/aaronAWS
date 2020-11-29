variable "ssm_patching_bucket_name" { }

resource "aws_s3_bucket" "ssm_patching_bucket" {
  bucket = "${var.ssm_patching_bucket_name}"
  acl    = "private"
}