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
                "route53:ListResourceRecordSets",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": "arn:aws:route53:::hostedzone/Z1TYC32TBZDQQI"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-client-config/ppv-${dev-tst-dem-int}-tenant${tenant_number}/*"
        }
    ]
}