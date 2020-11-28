{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-appdata",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "ppv-${dev-tst-dem-int}-tenant${tenant_number}/*"
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
            "Resource": "arn:aws:s3:::ppv-dev-appdata/ppv-${dev-tst-dem-int}-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-client-config/ppv-${dev-tst-dem-int}-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-backups",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "postgres_backup/ppv-${dev-tst-dem-int}-tenant${tenant_number}/"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-backups/postgres_backup/ppv-${dev-tst-dem-int}-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:DescribeAutoScalingGroups",
            "Resource": "*"
        }
    ]
}