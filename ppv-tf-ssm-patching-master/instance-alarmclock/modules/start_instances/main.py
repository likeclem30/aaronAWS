import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
region = 'us-east-1'

def lambda_handler(event, context):
    environments = os.environ['ENVIRONMENTS'].split(',')
    ec2 = boto3.resource('ec2')
    client = boto3.client('ec2')
    for environment in environments:
        logging.info('Starting instances for environment: {}'.format(environment))
        filters = []
        filters.append(
            {
                'Name': 'tag:Environment',
                'Values': [environment]
            }
        )
        instances = ec2.instances.filter(Filters=filters)
        instance_list = []
        for instance in instances:
            instance_list.append(instance.id)
        client.start_instances(InstanceIds=instance_list)

    return {
        "statusCode": 200,
        "body": json.dumps('Start Script Done')
    }