{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketMultipartUploads",
                "s3:ListBucketVersions",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-backups/postgres_backup/con-tenant${tenant_number}/*"   
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-backups/elasticsearch_backup/ppv-con-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetAccountPublicAccessBlock",
            "Resource": "*"
        }
    ]
}