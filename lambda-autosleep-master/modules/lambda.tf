variable "lambda_function_name" { }
variable "lambda_env_var_tag_values" { }

data "archive_file" "code_source" {
    type = "zip"
    source_dir = "autosleep_function"
    output_path = "autosleep_function.zip"
}

resource "aws_lambda_function" "autosleep" {
  filename = "autosleep_function.zip"
  function_name = "${var.lambda_function_name}"
  role = "${aws_iam_role.lambda_service_role.arn}"
  runtime = "python3.6"
  handler = "main.lambda_handler"
  timeout = 300
  memory_size = 256
  source_code_hash = "${data.archive_file.code_source.output_base64sha256}"

  environment {
      variables = {
          tags = "${var.lambda_env_var_tag_values}"
      }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.autosleep.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.autosleep_bucket.arn}"
}