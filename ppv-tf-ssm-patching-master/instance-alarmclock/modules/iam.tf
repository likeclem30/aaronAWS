variable "lambda_policy_name" { }
variable "lambda_role_name" { }

data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups"
    ]
    resources = [
      "*"
      ]
  }
  statement {
    actions = [
      "ec2:StartInstances",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_instance_policy" {
  statement {
  actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_execution" {
  name = "${var.lambda_policy_name}"
  path = "/"
  policy = "${data.aws_iam_policy_document.lambda_execution_policy.json}"
}

resource "aws_iam_role" "lambda_service_role" {
  name = "${var.lambda_role_name}"
  assume_role_policy  = "${data.aws_iam_policy_document.lambda_instance_policy.json}"
}

resource "aws_iam_policy_attachment" "lambda_role_attachment" {
  name = "lambda_policy_role_attachment"
  roles = [
    "${aws_iam_role.lambda_service_role.name}"
  ]
  policy_arn = "${aws_iam_policy.lambda_execution.arn}"
}