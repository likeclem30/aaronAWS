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
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::ndm-ppv-npn-appdata/ppv-stg-tenant${tenant_number}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteTable",
                "dynamodb:CreateTable",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:UpdateTable",
                "dynamodb:GetRecords",
                "dynamodb:ListTables"
            ],
            "Resource": "arn:aws:dynamodb:::table/EmrFSMetadataStgTenant${tenant_number}"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:SetInstanceHealth",
            "Resource": "arn:aws:autoscaling:*:392164873763:autoScalingGroup:*:autoScalingGroupName/ppv-stg-tenant${tenant_number}-spark*"
        }
    ]
}