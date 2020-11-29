#!/Users/Hector_Bastos/Documents/github/mash-periscope/akamai-jobs/.venv/bin/python
# -*- coding: utf-8 -*-
"""Activate version for Akamai property

This script it is used to be able to create new property version on Akamai for
Periscope solutions.

Example:
    Examples can be given using either the ``Example`` or ``Examples``
    sections. Sections support any reStructuredText formatting, including
    literal blocks::

        $ python example_google.py

Attributes:
    module_level_variable1 (int): Module level variables may be documented in
        either the ``Attributes`` section of the module docstring, or in an
        inline docstring immediately following the variable.

        Either form is acceptable, but the two should not be mixed. Choose
        one convention to document module level variables and be consistent
        with it.

Todo:
    * Increase scope of script for all Akamai properties on Cube Tech
"""

import os
import requests
import json
import re
import logging
import pprint
import base64
from akamai.edgegrid import EdgeGridAuth
from urllib.parse import urljoin

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Define Akamai Keys
if os.getenv('AKAMAI_KEYS') is None:
    logging.error('AKAMAI_KEYS environment variable needs to be defined.')
    exit(-1)

keys = json.loads(base64.b64decode(os.environ['AKAMAI_KEYS']))

# Keys used on Akamai API.
akamai_keys = {
    'client_secret': keys['client_secret'],
    'host': keys['base_url'],
    'access_token': keys['access_token'],
    'client_token': keys['client_token'],
    'groupId': 'grp_77280',  # Akamai group id for 'New Ventures'
    'contractId': 'M-1P32RO9',
    'propertyId': 'prp_443185'  # Property Id for Periscope Solutions
}

# Names of rules that can't be changed.
UNAUTHORIZED_RULE_NAMES = [
    'default',
    '/cvs/assortment',
    'app-stg.periscope-solutions.com',
    'tableau.periscope-solutions.com',
    'tableau-npn.periscope-solutions.com',
    'lvn-app',
    'Performance',
    'Compressible Objects',
    'Offload',
    'CSS and JavaScript',
    'Static Objects'
]

def get_latest_property_version():
    session = requests.Session()
    session.auth = EdgeGridAuth(
        client_token=akamai_keys['client_token'],
        client_secret=akamai_keys['client_secret'],
        access_token=akamai_keys['access_token']
    )

    logger.info('Getting all property versions...')
    querystring = {
        'contractId': akamai_keys['contractId'],
        'groupId': akamai_keys['groupId']
    }
    path = '/papi/v1/properties/{}/versions'.format(akamai_keys['propertyId'])
    url = urljoin(akamai_keys['host'], path)
    try:
        response = session.get(
            url=url,
            params=querystring
        )
        response.raise_for_status()
    except requests.exceptions.HTTPError as http_error:
        logging.error(http_error)
        exit(-1)
    except requests.exceptions.ConnectionError as connection_error:
        logging.error(connection_error)
        exit(-1)
    except requests.exceptions.RequestException as error:
        logging.error(error)
        exit(-1)
    # Get current active version
    versions = response.json()['versions']['items']
    for version in versions:
        logging.info('Found latest veresion: {}'.format(version['propertyVersion']))
        return version['propertyVersion']
    
def generate_rule():
    logging.info('Generating rule template.')
    # Base rule
    new_rule = {
        "name": os.environ['RULE_NAME'],
        "children": [],
        "behaviors": [],
        "criteria": [
            {
                "name": "hostname",
                "options": {
                    "matchOperator": "IS_ONE_OF",
                    "values": [
                        os.environ['RULE_HOSTNAME']
                    ]
                }
            }
        ],
        "criteriaMustSatisfy": "all"
    }

    origin_server_behavior = {
        "name": "origin",
        "options": {
            "originType": "CUSTOMER",
            "hostname": os.environ['BEHAVIOR_ORIGIN_HOSTNAME'],
            "forwardHostHeader": "REQUEST_HOST_HEADER",
            "cacheKeyHostname": "ORIGIN_HOSTNAME",
            "compress": True,
            "enableTrueClientIp": True,
            "originCertificate": "",
            "verificationMode": "CUSTOM",
            "ports": "",
            "httpPort": 80,
            "httpsPort": 443,
            "originSni": False,
            "trueClientIpHeader": "True-Client-IP",
            "trueClientIpClientSetting": False,
            "customValidCnValues": [
                "{{Origin Hostname}}",
                "{{Forward Host Header}}"
            ],
            "originCertsToHonor": "COMBO",
            "standardCertificateAuthorities": [
                "akamai-permissive",
                "THIRD_PARTY_AMAZON"
            ],
            "customCertificateAuthorities": [],
            "customCertificates": []
        }
    }
    new_rule['behaviors'].append(origin_server_behavior)

    websockets_behavior = {
        "name": "webSockets",
        "options": {
            "enabled": True
        }
    }
    new_rule['behaviors'].append(websockets_behavior)

    caching_behavior = {
        "name": "caching",
        "options": {
            "behavior": "NO_STORE"
        }
    }
    new_rule['behaviors'].append(caching_behavior)

    if os.environ['READ_TIMEOUT'] == 'true':
        read_timeout_behavior = {
            "name": "readTimeout",
            "options": {
                "value": os.environ['READ_TIMEOUT_SECONDS']
            }
        }
        new_rule['behaviors'].append(read_timeout_behavior)

    if os.environ['HTTP_TIMEOUT'] == 'true':
        http_timeout = {
            "name": "timeout",
            "options": {
                "value": os.environ['HTTP_TIMEOUT_SECONDS']
            }
        }
        new_rule['behaviors'].append(http_timeout)

    if os.environ['BEHAVIOR_ALLOW_HTTP_METHODS'] == "true":
        allow_http_methods_behavior = {
            "name": "allHttpInCacheHierarchy",
            "options": {
                "enabled": True
            }
        }
        new_rule['behaviors'].append(allow_http_methods_behavior)

    logging.info('Rule template created.')
    logging.info(json.dumps(new_rule, indent=4, sort_keys=True))
    return new_rule

# Validate rule name
if not re.search(r'^t\d\d\d\d-', os.environ['RULE_NAME']):
    logging.info(
        'New rules to be created need to have the format tXXXX where X is a number.')
    exit(-1)

property_version = get_latest_property_version()

# Akamai Authentication
session = requests.Session()
session.auth = EdgeGridAuth(
    client_token=akamai_keys['client_token'],
    client_secret=akamai_keys['client_secret'],
    access_token=akamai_keys['access_token']
)

# Get property rules from Akamai
querystring = {
    'contractId': akamai_keys['contractId'],
    'groupId': akamai_keys['groupId'],
    'validateRules': 'true',
    'validateMode': 'fast'
}
path = '/papi/v1/properties/{}/versions/{}/rules'.format(
    akamai_keys['propertyId'],
    property_version
)
url = urljoin(akamai_keys['host'], path)
try:
    logging.info('Getting property rules for {} version {}'.format(
        akamai_keys['propertyId'],
        property_version
    ))
    response = session.get(
        url=url,
        params=querystring
    )
    response.raise_for_status()
    logging.info('Pulled property successfully.')
except requests.exceptions.HTTPError as http_error:
    logging.error(http_error)
    exit(-1)
except requests.exceptions.ConnectionError as connection_error:
    logging.error(connection_error)
    exit(-1)
except requests.exceptions.RequestException as error:
    logging.error(error)
    exit(-1)

# Validate if rule already exists
# If rule exists, it will rewrite rule
rules = response.json()['rules']
index = 0
rule_exists = False
for children in rules['children']:
    if children['name'] == os.environ['RULE_NAME']:
        logging.warning('Rule "{}" already exists.'.format(
            os.environ['RULE_NAME']))
        rule_exists = True
        break
    index += 1

# Run a dry run of new rule
new_rule = generate_rule()
if os.getenv('DELETE_RULE') and os.environ['DELETE_RULE'] == 'true' and rule_exists:
    logging.info('Deleting rule {}.'.format(rules['children'][index]['name']))
    del rules['children'][index]
elif not rule_exists:
    logging.info('Rule doesn\'t exist. Creating new one.')
    rules['children'].append(new_rule)
else:
    logging.warning('Rule "{}" exists. Modifying...'.format(
        os.environ['RULE_NAME']))
    rules['children'][index] = new_rule

querystring = {
    'contractId': akamai_keys['contractId'],
    'groupId': akamai_keys['groupId'],
    'validateRules': 'true',
    'validateMode': 'fast',
    'dryRun': 'true'
}
path = '/papi/v1/properties/{}/versions/{}/rules'.format(
    akamai_keys['propertyId'],
    property_version
)
url = urljoin(akamai_keys['host'], path)
headers = {
    'content-type': 'application/json'
}
body = {
    "rules": rules
}
try:
    logging.info('Validating if rule complies with Akamai format.')
    response = session.put(
        url=url,
        headers=headers,
        data=json.dumps(body),
        params=querystring
    )
    response.raise_for_status()
    logging.info('Rule format is correct.')
    logging.info('Response Code: {}'.format(response.status_code))
except requests.exceptions.HTTPError as http_error:
    logging.error(http_error)
    exit(-1)
except requests.exceptions.ConnectionError as connection_error:
    logging.error(connection_error)
    exit(-1)
except requests.exceptions.RequestException as error:
    logging.error(error)
    exit(-1)

if response.status_code != 200:
    logging.error('There was an issue.')

# Push changes to property
querystring = {
    'contractId': akamai_keys['contractId'],
    'groupId': akamai_keys['groupId'],
    'validateRules': 'true'
}

try:
    logging.info('Modifying property.')
    response = session.put(
        url=url,
        headers=headers,
        data=json.dumps(body),
        params=querystring
    )
    response.raise_for_status()
    logging.info('Poperty has been updated.')
    logging.info('Response Code: {}'.format(response.status_code))
except requests.exceptions.HTTPError as http_error:
    logging.error(http_error)
    exit(-1)
except requests.exceptions.ConnectionError as connection_error:
    logging.error(connection_error)
    exit(-1)
except requests.exceptions.RequestException as error:
    logging.error(error)
    exit(-1)
