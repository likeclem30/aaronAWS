provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_iam_role" "promo" {
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


resource "aws_iam_instance_profile" "promo_instance_profile" {
  count = length(var.all_roles)
  name  = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  role  = aws_iam_role.promo[count.index].name
}

## 1 AWS policies 

resource "aws_iam_role_policy_attachment" "aws_managed_policy-1" {
  count      = "${length(var.all_roles)}"
  role       = aws_iam_role.promo[count.index].name
  policy_arn = var.aws_managed_policies[0]
  depends_on = ["aws_iam_role.promo"]
}


## 6 Managed Policies 


resource "aws_iam_role_policy_attachment" "ppv_prod_ssm_policy" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[0]
  depends_on = ["aws_iam_role_policy_attachment.aws_managed_policy-1"]
}
resource "aws_iam_role_policy_attachment" "ppv_policy_get_bitdefender" {
  count      = "${length(var.bit)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.bit[count.index]}"
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
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[3]
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_copy_s3_encrypted_objects"]
}
resource "aws_iam_role_policy_attachment" "s3_common_ro" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[4]
  depends_on = ["aws_iam_role_policy_attachment.route53_manage_private_hz"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_manage_encrypted_volumes" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_con_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[5]
  depends_on = ["aws_iam_role_policy_attachment.s3_common_ro"]
}



## 4 Inline Policies 

data "template_file" "inline_tenant_inline" {
  template = file("./inline_policies/tenant_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_tenant_inline" {
  name       = "tenant_inline"
  role       = aws_iam_role.promo[0].name
  policy     = "${data.template_file.inline_tenant_inline.rendered}"
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_manage_encrypted_volumes"]
}

data "template_file" "inline_data_inline" {
  template = file("./inline_policies/data_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_data_inline" {
  name   = "data_inline"
  role   = aws_iam_role.promo[1].name
  policy = "${data.template_file.inline_data_inline.rendered}"
}

data "template_file" "inline_jenkins_inline" {
  template = file("./inline_policies/jenkins_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_jenkins_inline" {
  name   = "jenkins_inline"
  role   = aws_iam_role.promo[3].name
  policy = "${data.template_file.inline_jenkins_inline.rendered}"
}

data "template_file" "inline_mgmt_inline" {
  template = file("./inline_policies/mgmt_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_mgmt_inline" {
  name   = "mgmt_inline"
  role   = aws_iam_role.promo[4].name
  policy = "${data.template_file.inline_mgmt_inline.rendered}"
}



terraform {
   backend "s3" {
     bucket         = "ndm-ppv-tfstate"
     encrypt        = true
     region         =  "us-east-1"
     key            = "terraform.tfstate"
   }
 }
