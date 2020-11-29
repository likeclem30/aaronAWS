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

# If rule doesn't exist, application will give a warning message and exit
if not rule_exists:
    logging.warning('Rule {} doesn\'t exist. Please create first before trying to modify...'.format(
        os.environ['RULE_NAME']))
    exit(-1)

# Modify rule
rule = rules['children'][index]
logging.info('Modifying rule: {}.'.format(os.environ['RULE_NAME']))

# Modify Hostname
if os.environ['MODIFY_HOSTNAME'] == 'true':
    logging.info('Modifying hostname...')
    rule['criteria'][0]['options']['values'][0] = os.environ['HOSTNAME']

# Modify Origin Server
if os.environ['MODIFY_ORIGIN_SERVER'] == 'true':
    logging.info('Modifying origin server...')
    index = 0
    for behavior in rule['behaviors']:
        if behavior['name'] == 'origin':
            rule['behaviors'][index]['options']['hostname'] = os.environ['ORIGIN_SERVER']
            break
        index += 1

# Modify Caching behavior
if os.environ['CACHING'] != 'no-action':
    logging.info('Modifying Caching behavior...')
    behavior_exists = False
    index = 0
    for behavior in rule['behaviors']:
        if behavior['name'] == 'caching':
            if os.environ['CACHING'] == 'enable':
                logging.info('Found Caching behavior. Removing behavior...')
                del rule['behaviors'][index]
                behavior_exists = True
                break
            elif os.environ['CACHING'] == 'disable':
                logging.info('Caching behavior already configured...')
                logging.info(json.dumps(rule['behaviors'][index], indent=4))
                behavior_exists = True
                break
        index += 1
    if not behavior_exists and os.environ['CACHING'] == 'disable':
        logging.info('Adding Caching behavior...')
        caching_behavior = {
            'name': 'caching',
            'options': {
                'behavior': 'NO_STORE'
            }
        }
        rule['behaviors'].append(caching_behavior)

# Modify Allow All HTTP methods behavior
if os.environ['ALLOW_ALL_HTTP_METHODS'] != 'no-action':
    behavior_exists = False
    index = 0
    http_methods_enabled = True if os.environ['ALLOW_ALL_HTTP_METHODS'] == 'enable' else False
    for behavior in rule['behaviors']:
        if behavior['name'] == 'allHttpInCacheHierarchy':
            logging.info('Found Allow HTTP Method behavior. Modifying...')
            rule['behaviors'][index]['options']['enabled'] = http_methods_enabled
            behavior_exists = True
            break
        index += 1
    if not behavior_exists:
        logging.info('Adding Allow HTTP Methods behavior...')
        allow_http_methods_behavior = {
            'name': 'allHttpInCacheHierarchy',
            'options': {
                'enabled': http_methods_enabled
            }
        }
        rule['behaviors'].append(allow_http_methods_behavior)

# Modify Read Timeout
if os.environ['MODIFY_READ_TIMEOUT'] == 'true':
    behavior_exists = False
    index = 0
    for behavior in rule['behaviors']:
        if behavior['name'] == 'readTimeout':
            logging.info('Found Read Timeout behavior. Modifying...')
            rule['behaviors'][index]['options']['value'] = os.environ['READ_TIMEOUT']
            behavior_exists = True
            break
        index += 1
    if not behavior_exists:
        logging.info('Adding Read timeout behavior.')
        read_timeout_behavior = {
            "name": "readTimeout",
            "options": {
                "value": os.environ['READ_TIMEOUT']
            }
        }
        rule['behaviors'].append(read_timeout_behavior)

# Modify HTTP Timeout
if os.environ['MODIFY_HTTP_TIMEOUT'] == 'true':
    behavior_exists = False
    index = 0
    for behavior in rule['behaviors']:
        if behavior['name'] == 'timeout':
            logging.info('Found HTTP Timeout behavior. Modifying...')
            rule['behaviors'][index]['options']['value'] = os.environ['READ_TIMEOUT']
            behavior_exists = True
            break
        index += 1
    if not behavior_exists:
        logging.info('Adding HTTP Timeout behavior.')
        http_timeout_behavior = {
            "name": "timeout",
            "options": {
                "value": "599s"
            }
        }
        rule['behaviors'].append(http_timeout_behavior)

logging.info('Finished modifying rule.')
logging.info(json.dumps(rule, indent=4))


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
