import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_ec2_instances(tags, values):
    ec2 = boto3.resource('ec2')

    filters = [ ]
    for i in range(0, len(tags)):
        filters.append(
            {
                'Name': 'tag:{}'.format(tags[i]),
                'Values': [values[i]]
            }
        )
    filters.append(
        { 
            'Name': 'tag:pause_exclude',
            'Values': ["false"]
        }
    )
    return ec2.instances.filter(Filters=filters)

def get_asg_name(instance):
    for tag in instance.tags:
        if tag['Key'] == 'aws:autoscaling:groupName':
            logger.info(
                'Instance %s part of Autoscaling group %s.',
                instance.id,
                tag['Value']
            )
            return tag['Value']
    return None

def get_scaling_tag_values(tags, prefix=""):
    values = { }
    count = 0
    for tag in tags:
        if tag['Key'] == '{}maxSize'.format(prefix):
            values['maxSize'] = tag['Value']
            count+=1
            continue
        elif tag['Key'] == '{}minSize'.format(prefix):
            values['minSize'] = tag['Value']
            count+=1
            continue
        elif tag['Key'] == '{}desiredCapacity'.format(prefix):
            values['desiredCapacity'] = tag['Value']
            count+=1
            continue
    
    results = {
        "count": count,
        "values": values
    }

    return results

def resize_asg(tag_keys, tag_values, file_size):
    client = boto3.client('autoscaling')
    query = 'AutoScalingGroups[]'
    for i in range(0, len(tag_keys)):
        query = '{} | [?contains(Tags[?Key==`"{}"`].Value, `"{}"`)]'.format(
            query, tag_keys[i], tag_values[i]
        )
    query = '{} | [?contains(Tags[?Key==`"pause_exclude"`].Value, `"false"`)]'.format(query)
    
    while True:
        paginator = client.get_paginator('describe_auto_scaling_groups')
        page_iterator = paginator.paginate(
            PaginationConfig={'PageSize': 100}
        )
        for page in page_iterator:
            filtered_asgs = page_iterator.search(query)
            for asg in filtered_asgs:
                logging.info(asg)
                asg_name = asg['AutoScalingGroupName']
                if file_size == 0:
                    scaling_values = get_scaling_tag_values(asg['Tags'], 'sleep_')
                else:
                    scaling_values = get_scaling_tag_values(asg['Tags'])

                if scaling_values["count"] < 3:
                    logging.warning(
                        "Autoscaling group %s doesn't have all three sleep and/or wake properties configured.",
                        asg_name
                    )
                    continue

                response = client.update_auto_scaling_group(
                    AutoScalingGroupName=asg_name,
                    MinSize=int(scaling_values['values']['minSize']),
                    MaxSize=int(scaling_values['values']['maxSize']),
                    DesiredCapacity=int(scaling_values['values']['desiredCapacity'])
                )

                logging.info(response)

        try:
            marker = page['Marker']
        except KeyError:
            break
    
def start_stop_ec2_instances(tags, tag_values, file_size):
    instances = get_ec2_instances(tags, tag_values)
    for instance in instances:
        logging.info("Instance: %s", instance.id)
        asg_name = get_asg_name(instance)
        if asg_name:
            logging.info('Skipping instance %s. Part of autoscaling group %s', instance.id, asg_name)
            continue

        if file_size == 0:
            logger.info(
                'Stopping Instance: %s.',
                instance.id
            )
            instance.stop()
        else:
            logger.info(
                'Starting Instance: %s.',
                instance.id
            )
            instance.start()

def lambda_handler(event, context):
    tags = os.environ['tags'].split(',')
    s3_json = event['Records'][0]['s3']
    tag_values = s3_json['object']['key'].split('/')
    file_size = s3_json['object']['size']

    #Resizing ASGS
    resize_asg(tags, tag_values, file_size)

    #Stop or Start instances
    start_stop_ec2_instances(tags, tag_values, file_size)

    return {
        "statusCode": 200,
        "body": json.dumps('Autosleep Script Done')
    }