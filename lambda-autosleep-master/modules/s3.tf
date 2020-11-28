variable "s3_bucket_name" { }

resource "aws_s3_bucket" "autosleep_bucket" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
}

resource "aws_s3_bucket_notification" "autosleep_notification" {

  bucket = "${aws_s3_bucket.autosleep_bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.autosleep.arn}"
    events = ["s3:ObjectCreated:*"]
  }
}
