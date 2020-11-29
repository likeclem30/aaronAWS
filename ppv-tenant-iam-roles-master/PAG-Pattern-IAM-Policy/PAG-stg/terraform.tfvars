region  = "us-east-1"
# profile = "stg"

aws_managed_policies = [
  "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
]

managed_policies = [
  "arn:aws:iam::392164873763:policy/ppv_npn_ssm_policy",
  "arn:aws:iam::392164873763:policy/ppv_policy_get_bitdefender",
  "arn:aws:iam::392164873763:policy/ppv_kms_copy_s3_encrypted_objects",
  "arn:aws:iam::392164873763:policy/route53_manage_private_hz",
  "arn:aws:iam::392164873763:policy/s3_common_ro",
  "arn:aws:iam::392164873763:policy/ppv_kms_manage_encrypted_volumes",
  "arn:aws:iam::392164873763:policy/stg-ec2_autoscaling_access",
  "arn:aws:iam::392164873763:policy/ppv_byok_kms_key_access",
  "arn:aws:iam::392164873763:policy/spark_create_tag",
  "arn:aws:iam::392164873763:policy/ppv_kms_manage_encrypted_volumes-CMK",
  "arn:aws:iam::392164873763:policy/ppv_kms_copy_s3_encrypted_objects-CMK"
]

all_roles        = ["", "_elasticsearch", "_jenkins", "_mgmt", "_rdp", "_spark"]
route53          = ["", "_mgmt", "_spark"]
s3_common        = ["", "_spark"]
stg_ec2          = ["", "_jenkins", "_mgmt"]