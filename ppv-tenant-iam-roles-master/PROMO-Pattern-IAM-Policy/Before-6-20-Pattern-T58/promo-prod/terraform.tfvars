region  = "us-east-1"


# 0 - 1 Policies
aws_managed_policies = [
  "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
]

# 0 - 8 Policies
managed_policies = [
  "arn:aws:iam::949421251013:policy/ppv_prod_ssm_policy",
  "arn:aws:iam::949421251013:policy/ppv_policy_get_bitdefender",
  "arn:aws:iam::949421251013:policy/ppv_kms_copy_s3_encrypted_objects",
  "arn:aws:iam::949421251013:policy/con-ec2_autoscaling_access",
  "arn:aws:iam::949421251013:policy/route53_manage_private_hz",
  "arn:aws:iam::949421251013:policy/s3_common_ro",
  "arn:aws:iam::949421251013:policy/ppv_kms_manage_encrypted_volumes",
  "arn:aws:iam::949421251013:policy/spark_create_tag",
  "arn:aws:iam::949421251013:policy/byok_kms_key_access"
]

# 0 - 9 Roles 
###################  0      1       2            3       4         5              6      7          ############    
all_roles        = ["", "_data", "_jenkins", "_mgmt", "_promo", "_promo_mgmt", "_rdp", "_spark"]
bit              = ["", "_data", "_jenkins", "_mgmt", "_promo", "_spark"]
con_ec2          = ["", "_jenkins"]



