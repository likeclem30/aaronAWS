provider "aws" {
  region = var.region
  #profile = var.profile
}

## 6 Roles 

resource "aws_iam_role" "pas" {
  count = "${length(var.all_roles)}"
  name  = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "pas_instance_profile" {
  count = length(var.all_roles)
  name  = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  role  = aws_iam_role.pas[count.index].name
}

## 2 AWS policies 

resource "aws_iam_role_policy_attachment" "aws_managed_policy-1" {
  count      = "${length(var.all_roles)}"
  role       = aws_iam_role.pas[count.index].name
  policy_arn = var.aws_managed_policies[0]
  depends_on = ["aws_iam_role.pas"]
}

resource "aws_iam_role_policy_attachment" "aws_managed_policy-2" {
  role       = aws_iam_role.pas[6].name
  policy_arn = var.aws_managed_policies[1]
  depends_on = [aws_iam_role_policy_attachment.aws_managed_policy-1]
}

## 7 Managed Policies 


resource "aws_iam_role_policy_attachment" "ppv_prod_ssm_policy" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[0]
  depends_on = ["aws_iam_role_policy_attachment.aws_managed_policy-2"]
}
resource "aws_iam_role_policy_attachment" "ppv_policy_get_bitdefender" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[1]
  depends_on = ["aws_iam_role_policy_attachment.ppv_prod_ssm_policy"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_copy_s3_encrypted_objects" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[2]
  depends_on = ["aws_iam_role_policy_attachment.ppv_policy_get_bitdefender"]
}
resource "aws_iam_role_policy_attachment" "route53_manage_private_hz" {
  count      = "${length(var.route53)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.route53[count.index]}"
  policy_arn = var.managed_policies[3]
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_copy_s3_encrypted_objects"]
}
resource "aws_iam_role_policy_attachment" "s3_common_ro" {
  count      = "${length(var.s3_common)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.s3_common[count.index]}"
  policy_arn = var.managed_policies[4]
  depends_on = ["aws_iam_role_policy_attachment.route53_manage_private_hz"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_manage_encrypted_volumes" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[5]
  depends_on = ["aws_iam_role_policy_attachment.s3_common_ro"]
}
resource "aws_iam_role_policy_attachment" "spark_create_tag" {
  role       = aws_iam_role.pas[6].name
  policy_arn = var.managed_policies[6]
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_manage_encrypted_volumes"]
}

## 3 Inline Policies 


#tenant_elasticsearch

data "template_file" "inline_elasticsearch_inline" {
  template = file("./inline_policies/elasticsearch_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_elasticsearch_inline" {
  name   = "elasticsearch_inline"
  role   = aws_iam_role.pas[1].name
  policy = "${data.template_file.inline_elasticsearch_inline.rendered}"
}


# tenant_mgmt


data "template_file" "inline_mgmt_inline" {
  template = file("./inline_policies/mgmt_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_mgmt_inline" {
  name   = "mgmt_inline"
  role   = aws_iam_role.pas[4].name
  policy = "${data.template_file.inline_mgmt_inline.rendered}"
}


# tenant_spark

data "template_file" "inline_spark_inline" {
  template = file("./inline_policies/spark_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_spark_inline" {
  name   = "spark_inline"
  role   = aws_iam_role.pas[6].name
  policy = "${data.template_file.inline_spark_inline.rendered}"
}


terraform {
   backend "s3" {
     bucket         = "ndm-ppv-tfstate"
     encrypt        = true
     region         =  "us-east-1"
     key            = "terraform.tfstate"
   }
 }
