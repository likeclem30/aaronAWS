import datetime
import dateutil
from dateutil import parser
import logging

import boto
from boto import iam

logger = logging.getLogger()
logger.setLevel(logging.INFO)

conn=iam.connect_to_region('us-east-2')
users=conn.get_all_users()
timeLimit=datetime.datetime.now() - datetime.timedelta(days=90)

logger.info("---------------------------------------------")
logger.info("Access Keys Date" + "\t\t" + "Username")
logger.info("---------------------------------------------")


for user in users.list_users_response.users:
    accessKeys=conn.get_all_access_keys(user_name=user['user_name'])
    for keysCreatedDate in accessKeys.list_access_keys_response.list_access_keys_result.access_key_metadata:

        if parser.parse(keysCreatedDate['create_date']).date() <= timeLimit.date():

            logger.info(keysCreatedDate['create_date']) + "\t\t" + user['user_name']
