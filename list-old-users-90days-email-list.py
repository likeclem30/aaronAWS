import boto3, os, time, datetime, sys, json
from datetime import date
from typing import List
import logging
from botocore.exceptions import ClientError


logger = logging.getLogger()
logger.setLevel(logging.INFO)
iam = boto3.client('iam')


def get_recipents_mail()->List[str]:
    email_list = []
    for userlist in iam.list_users()['Users']:
            userKeys = iam.list_access_keys(UserName=userlist['UserName'])
            for keyValue in userKeys['AccessKeyMetadata']:
                    if keyValue['Status'] == 'Active':
                            currentdate = date.today()
                            active_days = currentdate - \
                                keyValue['CreateDate'].date()
                            if active_days >= datetime.timedelta(days=90):
                                userTags = iam.list_user_tags(
                                    UserName=keyValue['UserName'])
                                email_tag = list(filter(lambda tag: tag['Key'] == 'email', userTags['Tags']))
                                if(len(email_tag) == 1):
                                    email = email_tag[0]['Value']
                                    email_list.append(email)
    return email_list


def send_emails(unique_email: List[str]):
    RECIPIENTS = unique_email
    SENDER = "AWS SECURITY "
    AWS_REGION = os.environ.get("AWS_REGION", 'us-west-1')
    SUBJECT = "IAM Access Key Rotation"
    BODY_TEXT = ("Your IAM Access Key need to be rotated in AWS Account: 123456789 as it is 3 months or older.\r\n"
                "Log into AWS and go to your IAM user to fix: https://console.aws.amazon.com/iam/home?#security_credential"
                )
    BODY_HTML = """
    AWS Security: IAM Access Key Rotation: Your IAM Access Key need to be rotated in AWS Account: 123456789 as it is 3 months or older. Log into AWS and go to your https://console.aws.amazon.com/iam/home?#security_credential to create a new set of keys. Ensure to disable / remove your previous key pair.
                """
    CHARSET = "UTF-8"
    client = boto3.client('ses',region_name=AWS_REGION)
    try:
        response = client.send_email(
            Destination={
                'ToAddresses': RECIPIENTS,
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    except ClientError as e:
        logger.error(e.response['Error']['Message'])
    else:
        logger.info("Email sent! Message ID:"),
        logger.info(response['MessageId'])
    

def lambda_handler(event, context):
    logger.info("All IAM user emails that have AccessKeys 90 days or older")
    
    unique_emails = list(set(get_recipents_mail()))
    logger.info(f" {len(unique_emails)}")
    send_emails(unique_email=unique_emails)
    
    
