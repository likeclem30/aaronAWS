region  = "us-east-1"


# 0 - 1 Policies
aws_managed_policies = [
  "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
]

# 0 - 5 Policies
managed_policies = [
  "arn:aws:iam::392164873763:policy/ppv_npn_ssm_policy",
  "arn:aws:iam::392164873763:policy/ppv_policy_get_bitdefender",
  "arn:aws:iam::392164873763:policy/ppv_kms_copy_s3_encrypted_objects",
  "arn:aws:iam::392164873763:policy/route53_manage_private_hz",
  "arn:aws:iam::392164873763:policy/s3_common_ro",
  "arn:aws:iam::392164873763:policy/ppv_kms_manage_encrypted_volumes",
  "arn:aws:iam::392164873763:policy/ppv_kms_manage_encrypted_volumes-CMK",
  "arn:aws:iam::392164873763:policy/ppv_kms_copy_s3_encrypted_objects-CMK"
]

# 0 - 9 Roles 
###################  0      1       2          3        4         ############    
all_roles        = ["", "_data", "_jenkins", "_mgmt","_rdp"]
bit              = ["", "_data", "_jenkins", "_mgmt"]




