{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-appdata",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "ppv-stg-tenant${tenant_number}/*"
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
            "Resource": "arn:aws:s3:::ndm-ppv-npn-appdata/ppv-stg-tenant${tenant_number}/*"
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