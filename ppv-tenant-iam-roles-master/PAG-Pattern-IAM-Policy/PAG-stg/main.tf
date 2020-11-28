provider "aws" {
  region  = var.region
 # profile = var.profile
}

## 6 Roles 

resource "aws_iam_role" "pag" {
  count = "${length(var.all_roles)}"
  name  = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"

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


resource "aws_iam_instance_profile" "pag_instance_profile" {
  count = length(var.all_roles)
  name  = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  role  = aws_iam_role.pag[count.index].name
}

## 2 AWS policies 

resource "aws_iam_role_policy_attachment" "aws_managed_policy-1" {
  count      = "${length(var.all_roles)}"
  role       = aws_iam_role.pag[count.index].name
  policy_arn = var.aws_managed_policies[0]
  depends_on = ["aws_iam_role.pag"]
}

resource "aws_iam_role_policy_attachment" "aws_managed_policy-2" {
  role       = aws_iam_role.pag[5].name
  policy_arn = var.aws_managed_policies[1]
  depends_on = [aws_iam_role_policy_attachment.aws_managed_policy-1]
}

## 11 Managed Policies 


resource "aws_iam_role_policy_attachment" "ppv_npn_ssm_policy" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[0]
  depends_on = ["aws_iam_role_policy_attachment.aws_managed_policy-2"]
}
resource "aws_iam_role_policy_attachment" "ppv_policy_get_bitdefender" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[1]
  depends_on = ["aws_iam_role_policy_attachment.ppv_npn_ssm_policy"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_copy_s3_encrypted_objects" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[2]
  depends_on = ["aws_iam_role_policy_attachment.ppv_policy_get_bitdefender"]
}
resource "aws_iam_role_policy_attachment" "route53_manage_private_hz" {
  count      = "${length(var.route53)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.route53[count.index]}"
  policy_arn = var.managed_policies[3]
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_copy_s3_encrypted_objects"]
}
resource "aws_iam_role_policy_attachment" "s3_common_ro" {
  count      = "${length(var.s3_common)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.s3_common[count.index]}"
  policy_arn = var.managed_policies[4]
  depends_on = ["aws_iam_role_policy_attachment.route53_manage_private_hz"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_manage_encrypted_volumes" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[5]
  depends_on = ["aws_iam_role_policy_attachment.s3_common_ro"]
}
resource "aws_iam_role_policy_attachment" "stg-ec2_autoscaling_access" {
  count      = "${length(var.stg_ec2)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.stg_ec2[count.index]}"
  policy_arn = var.managed_policies[6]
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_manage_encrypted_volumes"]
}
resource "aws_iam_role_policy_attachment" "ppv_byok_kms_key_access" {
  role       = aws_iam_role.pag[5].name
  policy_arn = var.managed_policies[7]
  depends_on = ["aws_iam_role_policy_attachment.stg-ec2_autoscaling_access"]
}
resource "aws_iam_role_policy_attachment" "spark_create_tag" {
  role       = aws_iam_role.pag[5].name
  policy_arn = var.managed_policies[8]
  depends_on = ["aws_iam_role_policy_attachment.ppv_byok_kms_key_access"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_manage_encrypted_volumes-CMK" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[9]
  depends_on = ["aws_iam_role_policy_attachment.spark_create_tag"]
}
resource "aws_iam_role_policy_attachment" "ppv_kms_copy_s3_encrypted_objects-CMK" {
  count      = "${length(var.all_roles)}"
  role       = "ppv_svcrole_stg_tenant${var.tenant_number}${var.all_roles[count.index]}"
  policy_arn = var.managed_policies[10]
  depends_on = ["aws_iam_role_policy_attachment.ppv_kms_manage_encrypted_volumes-CMK"]
}

## 5 Inline Policies 

# tenant

data "template_file" "inline_tenant_inline" {
  template = file("./inline_policies/tenant_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_tenant_inline" {
  name       = "tenant_inline"
  role       = aws_iam_role.pag[0].name
  policy     = "${data.template_file.inline_tenant_inline.rendered}"
  depends_on = ["aws_iam_role_policy_attachment.spark_create_tag"]
}



#tenant_elasticsearch

data "template_file" "inline_elasticsearch_inline" {
  template = file("./inline_policies/elasticsearch_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "inline_elasticsearch_inline" {
  name   = "elasticsearch_inline"
  role   = aws_iam_role.pag[1].name
  policy = "${data.template_file.inline_elasticsearch_inline.rendered}"
}


# tenant_jenkins

data "template_file" "jenkins_inline" {
  template = file("./inline_policies/jenkins_inline.tpl")
  vars = {
    tenant_number = "${var.tenant_number}"
  }
}
resource "aws_iam_role_policy" "jenkins_inline" {
  name   = "jenkins_inline"
  role   = aws_iam_role.pag[2].name
  policy = "${data.template_file.jenkins_inline.rendered}"
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
  role   = aws_iam_role.pag[3].name
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
  role   = aws_iam_role.pag[5].name
  policy = "${data.template_file.inline_spark_inline.rendered}"
}



terraform {
   backend "s3" {
     bucket         = "ndm-ppv-npn-tfstate"
     encrypt        = true
     region         =  "us-east-1"
     key            = "terraform.tfstate"
   }
 }
