#      - schedule: rate(1 day)
# cron(15 10 * * ? *) Every day 10:15
import boto3, json, time, datetime, sys, re
iam_client = boto3.client('iam')
sns_client = boto3.client('sns')
users = iam_client.list_users()
user_list = []
for key in users['Users']:
    user_list = key['UserName']
    accesskeys = iam_client.list_access_keys(UserName=key['UserName'])
    for items in user_list.split('\n'):
        for key in accesskeys['AccessKeyMetadata']:
            accesskeydate = accesskeys['AccessKeyMetadata'][0]['CreateDate']
            accesskeydate = accesskeydate.strftime("%Y-%m-%d %H:%M:%S")
            currentdate = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())
            accesskeyd = time.mktime(datetime.datetime.strptime(accesskeydate, "%Y-%m-%d %H:%M:%S").timetuple())
            currentd = time.mktime(datetime.datetime.strptime(currentdate, "%Y-%m-%d %H:%M:%S").timetuple())
            active_days = (currentd - accesskeyd)/60/60/24
            age_of_keys = (currentd - accesskeydate)/60/60/24
            message = (key['UserName'],int(round(age_of_keys))),
            message = re.sub(r'[^a-zA-Z0-9 ]', "", str(message))
            message = re.sub(r' ', ' is ', str(message))
            if active_days >= 90:
                print("The access key for " + str(message) + " days old. This user access key should be replaced ASAP.")
                """Publish to sns

                sns_client.publish(
                    TopicArn='arn:aws:sns:us-east-2:xxxxxxxxxxxxx:topic-name',
                    Subject='User with Old Access Key Detected',
                    Message="The access key for " + str(message) + " days old. This user access key should be replaced ASAP.",
                )
                """
