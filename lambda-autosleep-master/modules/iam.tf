variable "lambda_policy_name" { }
variable "lambda_role_name" { }
variable "s3_rw_policy_name" { }

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
      "ec2:StopInstances"
    ]
    condition {
      test = "Null"
      variable = "ec2:ResourceTag/pause_exclude"
      values = [
        "false"
      ]
    }
    resources = ["*"]
  }
  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    condition {
      test = "Null"
      variable = "autoscaling:ResourceTag/pause_exclude"
      values = [
        "false"
      ]
    }
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


data "aws_iam_policy_document" "autosleep_s3_rw_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.autosleep_bucket.arn}/*"
    ]
  }
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.autosleep_bucket.arn}"
    ]
  }
}

resource "aws_iam_policy" "s3_rw_policy" {
  name = "${var.s3_rw_policy_name}"
  path = "/"
  policy = "${data.aws_iam_policy_document.autosleep_s3_rw_policy.json}"
}