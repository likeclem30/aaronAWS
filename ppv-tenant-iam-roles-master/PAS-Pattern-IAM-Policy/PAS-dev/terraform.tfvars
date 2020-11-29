region = "us-east-1"


aws_managed_policies = [
  "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
]

managed_policies = [
  "arn:aws:iam::949421251013:policy/ppv_npn_ssm_policy",
  "arn:aws:iam::949421251013:policy/ppv_policy_get_bitdefender",
  "arn:aws:iam::949421251013:policy/ppv_kms_copy_s3_encrypted_objects",
  "arn:aws:iam::949421251013:policy/route53_manage_private_hz",
  "arn:aws:iam::949421251013:policy/s3_common_ro",
  "arn:aws:iam::949421251013:policy/ppv_kms_manage_encrypted_volumes",
  "arn:aws:iam::949421251013:policy/spark_create_tag",
  "arn:aws:iam::949421251013:policy/ppv_kms_manage_encrypted_volumes-CMK",
  "arn:aws:iam::949421251013:policy/ppv_kms_copy_s3_encrypted_objects-CMK"
]

all_roles = ["", "_elasticsearch", "_emr_nodes", "_jenkins", "_mgmt", "_rdp", "_spark"]
route53   = ["", "_elasticsearch", "_jenkins", "_mgmt", "_spark"]
s3_common = ["", "_emr_nodes", "_mgmt", "_spark"]