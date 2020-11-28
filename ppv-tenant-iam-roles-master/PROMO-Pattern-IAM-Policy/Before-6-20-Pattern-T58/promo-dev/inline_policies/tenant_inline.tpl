{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::ppv-dev-client-config/ppv-${dev-tst-dem-int}-tenant${tenant_number}/*"
        }
    ]
}