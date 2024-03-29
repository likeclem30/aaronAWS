{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-backups",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "${dev-tst-dem-int}-tenant${tenant_number}/"
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
            "Resource": [
                "arn:aws:s3:::ppv-dev-backup/${dev-tst-dem-int}-tenant${tenant_number}/*"
            ]
        }
    ]
}