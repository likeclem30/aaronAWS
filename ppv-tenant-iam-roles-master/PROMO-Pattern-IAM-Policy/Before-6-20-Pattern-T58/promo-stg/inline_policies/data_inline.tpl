{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-backups",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "sql_server_backup/stg-tenant${tenant_number}/"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-backups/sql_server_backup/stg-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-backups-replica",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "sql_server_backup/stg-tenant${tenant_number}/"
                }
            }
        }
    ]
}