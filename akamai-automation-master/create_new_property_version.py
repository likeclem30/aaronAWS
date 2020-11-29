#!/Users/Hector_Bastos/Documents/github/mash-periscope/akamai-jobs/.venv/bin/python
# -*- coding: utf-8 -*-
"""Create version for Akamai property

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

# Akamai Authentication
session = requests.Session()
session.auth = EdgeGridAuth(
    client_token=akamai_keys['client_token'],
    client_secret=akamai_keys['client_secret'],
    access_token=akamai_keys['access_token']
)

# TODO: Get all properties
# '/papi/v1/properties?contractId={}&groupId={}'.format(akamai_keys['contractId'],akamai_keys['groupId'])

# Get all versions for Periscope property
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
activeVersion = {}
for version in versions:
    if version['productionStatus'] == 'ACTIVE':
        activeVersion = version
        break
logger.info("Active version found: {}".format(activeVersion))

# Create a new property version
logging.info('Creating new property version...')
body = {
    'createFromVersion': activeVersion['propertyVersion'],
    'createFromVersionEtag': activeVersion['etag']
}
path = '/papi/v1/properties/{}/versions'.format(akamai_keys['propertyId'])
headers = {
    'content-type': 'application/json'
}
url = urljoin(akamai_keys['host'], path)
try:
   response = session.post(
       url=url,
       data=json.dumps(body),
       headers=headers,
       params=querystring
   )
except requests.exceptions.HTTPError as http_error:
   logging.error(http_error)
   exit(-1)
except requests.exceptions.ConnectionError as connection_error:
   logging.error(connection_error)
   exit(-1)
except requests.exceptions.RequestException as error:
   logging.error(error)
   exit(-1)
logger.info("New version created: {}".format(response.json()))
