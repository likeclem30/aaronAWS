{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-appdata/ppv-stg-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-client-config/ppv-stg-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DescribeSecurityGroups",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-backups",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "postgres_backup/ppv-stg-tenant${tenant_number}/"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-backups/postgres_backup/ppv-stg-tenant${tenant_number}/*"
        },
        {
            "Resource": [
                "arn:aws:s3:::ndm-ppv-npn-maintenance/stg-tenant${tenant_number}/*",
                "arn:aws:s3:::ndm-ppv-npn-maintenance/stg-tenant${tenant_number}"
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