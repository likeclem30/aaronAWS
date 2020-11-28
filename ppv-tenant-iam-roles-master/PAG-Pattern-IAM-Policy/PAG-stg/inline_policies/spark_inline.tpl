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
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:DeleteTable",
                "dynamodb:DescribeTable",
                "dynamodb:ListTables",
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetRecords",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:UpdateTable",
                "dynamodb:Scan",
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem"
            ],
            "Resource": "arn:aws:dynamodb:::table/EmrFSMetadataStgTenant${tenant_number}"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:SetInstanceHealth",
            "Resource": "arn:aws:autoscaling:us-east-1:392164873763:autoScalingGroup:*:autoScalingGroupName/ppv-stg-tenant${tenant_number}-spark*"
        }
    ]
}