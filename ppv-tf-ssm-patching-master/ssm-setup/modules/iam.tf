resource "aws_iam_role" "ssm_role" {
  name = "SSMPatchingRole"

  assume_role_policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"",
         "Effect":"Allow",
         "Principal":{
            "Service":[
               "ec2.amazonaws.com",
               "ssm.amazonaws.com"
            ]
         },
         "Action":"sts:AssumeRole"
      }
   ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "SSM_MW_role" {
  role       = "${aws_iam_role.ssm_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

output "ssm_role_arn" {
  value = "${aws_iam_role.ssm_role.arn}"
}
