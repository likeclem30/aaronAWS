import json
import os
import logging
import requests
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_api_key():
    client = boto3.client("ssm")
    response = client.get_parameter(
        Name=os.getenv("NEW_RELIC_INFRA_API_PARAMETER_NAME"),
        WithDecryption=True
    )
    return response["Parameter"]["Value"]

api_infra_key = get_api_key()

def create_policy(policy_name):
    url = "https://api.newrelic.com/v2/alerts_policies.json"
    
    try:
        response = requests.get(
            url,
            headers={
                "x-api-key": api_infra_key,
                "cache-control": "no-cache"
            },
            params={
                "filter[name]": policy_name
            }
        )
        logger.info(response.text)
    except requests.exceptions.HTTPError as errh:
        logger.error("HTTP Error: {}".format(errh))
    except requests.exceptions.ConnectionError as errc:
        logger.error("Connection Error: {}".format(errc))
    except requests.exceptions.Timeout as errt:
        logger.error("Timeout Error: {}".format(errt))
    except requests.exceptions.RequestException as err:
        logger.error("Something happened: {}".format(err))

    if response.status_code != 200:
        print(response.text)
        exit(0)
    
    if response.json()["policies"]:
        print("Policy {} already exists".format(policy_name))
        return response.json()["policies"][0]["id"]
    
    payload = {
        "policy": {
            "incident_preference": "PER_POLICY",
            "name": policy_name
        }
    }
    try:
        response = requests.post(
            url,
            headers={
                "x-api-key": api_infra_key,
                "Content-Type": "application/json",
                "cache-control": "no-cache"
            },
            data=json.dumps(payload)
        )
    except requests.exceptions.HTTPError as errh:
        logger.error("HTTP Error: {}".format(errh))
    except requests.exceptions.ConnectionError as errc:
        logger.error("Connection Error: {}".format(errc))
    except requests.exceptions.Timeout as errt:
        logger.error("Timeout Error: {}".format(errt))
    except requests.exceptions.RequestException as err:
        logger.error("Something happened: {}".format(err))

    if response.status_code != 201:
        print(response.text)
        exit(0)

    return response.json()["policy"]["id"]

def assign_channels(policy_id, notification_channel_ids):
    url = "https://api.newrelic.com/v2/alerts_policy_channels.json"
    querystring = {
        "policy_id": policy_id,
        "channel_ids": notification_channel_ids
    }
    headers = {
        'Content-Type': "application/json",
        'x-api-key': api_infra_key,
        'cache-control': "no-cache",
    }

    try:
        response = requests.put(
            url,
            headers=headers,
            params=querystring
        )
        response.raise_for_status()
        logger.info(response.text)
    except requests.exceptions.HTTPError as errh:
        logger.error("HTTP Error: {}".format(errh))
    except requests.exceptions.ConnectionError as errc:
        logger.error("Connection Error: {}".format(errc))
    except requests.exceptions.Timeout as errt:
        logger.error("Timeout Error: {}".format(errt))
    except requests.exceptions.RequestException as err:
        logger.error("Something happened: {}".format(err))
    
    return response.status_code

def create_condition(policy_id, condition):
    url = "https://infra-api.newrelic.com/v2/alerts/conditions"
    headers = {
        'x-api-key': api_infra_key,
        'Content-Type': "application/json",
        'cache-control': "no-cache",
    }

    condition_id = condition_exists(policy_id, condition["data"]["name"])
    
    if not condition_id:
        print("Creating condition: {}".format(condition["data"]["name"]))
        condition["data"]["policy_id"]=policy_id
        http_method = "POST"
        logging.info(condition)

    else:
        print("Updating condition: {}".format(condition["data"]["name"]))
        http_method = "PUT"
        url = url + "/{}".format(condition_id)
        logging.info(condition)

    try:
        response = requests.request(
            http_method,
            url,
            data=json.dumps(condition),
            headers=headers
        )
        logger.info(response.text)
    except requests.exceptions.HTTPError as errh:
        logger.error("HTTP Error: {}".format(errh))
    except requests.exceptions.ConnectionError as errc:
        logger.error("Connection Error: {}".format(errc))
    except requests.exceptions.Timeout as errt:
        logger.error("Timeout Error: {}".format(errt))
    except requests.exceptions.RequestException as err:
        logger.error("Something happened: {}".format(err))
    return response.status_code

def condition_exists(policy_id, condition_name):
    url = "https://infra-api.newrelic.com/v2/alerts/conditions"
    querystring = {
        "policy_id": policy_id
    }
    headers = {
        'x-api-key': api_infra_key,
        'cache-control': "no-cache"
    }

    try:
        response = requests.get(
            url,
            headers=headers,
            params=querystring
        )
        logger.info(response.text)
    except requests.exceptions.HTTPError as errh:
        logger.error("HTTP Error: {}".format(errh))
    except requests.exceptions.ConnectionError as errc:
        logger.error("Connection Error: {}".format(errc))
    except requests.exceptions.Timeout as errt:
        logger.error("Timeout Error: {}".format(errt))
    except requests.exceptions.RequestException as err:
        logger.error("Something happened: {}".format(err))

    for data in response.json()["data"]:
        if data["name"] == condition_name:
            print("Found condition: {}".format(data["name"]))
            return data["id"]

    print("Not found any condition with name: {}".format(condition_name))
    return False

def main(event, context):
    tenant_object = event["Records"][0]["s3"]
    bucket = tenant_object["bucket"]["name"]
    key = tenant_object["object"]["key"]
    s3 = boto3.resource("s3")

    s3.Bucket(bucket).download_file(key, "/tmp/tenant.json")

    with open("/tmp/tenant.json") as f:
        data = json.load(f)

    policy_id = create_policy(data["policy_name"])
    assign_channels(policy_id, data["notification_channel_ids"])

    conditions = data["conditions"]
    for condition in conditions:
        create_condition(policy_id, condition)

    body = {
        "message": "Policy {} has been created.".format(policy_id),
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response