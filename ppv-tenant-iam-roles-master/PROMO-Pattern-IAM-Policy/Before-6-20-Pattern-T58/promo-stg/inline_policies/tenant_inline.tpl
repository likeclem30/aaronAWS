{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-client-config/ppv-stg-tenant${tenant_number}/*"
        }
    ]
}