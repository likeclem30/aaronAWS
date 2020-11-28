{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-appdata",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "ppv-con-tenant${tenant_number}/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-appdata/ppv-con-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "*"
        },
        {
            "Resource": [
                "arn:aws:s3:::ndm-ppv-maintenance/${s3-maintenance_name}/*",
                "arn:aws:s3:::ndm-ppv-maintenance/${s3-maintenance_name}",
                "arn:aws:s3:::ndm-ppv-maintenance/con-tenant${tenant_number}/*",
                "arn:aws:s3:::ndm-ppv-maintenance/con-tenant${tenant_number}"
            ],
            "Action": [
                "s3:List*",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow"
        }
    ]
}