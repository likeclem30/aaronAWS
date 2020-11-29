#!/bin/bash
set +euo pipefail
IFS=$'\n\t'

[[ -z "$KMS_KEY_ID" ]] && echo "the KMS key arn needs to be configured and set." && exit 1;
[[ -z "$SUBNET_ID" ]] && echo "SUBNET_ID environment variable should be set." && exit 1;
[[ -z "$SSH_KEYPAIR_NAME" ]] && echo "SSH_KEYPAIR_NAME environment variable should be set." && exit 1;
[[ -z "$SSH_PRIVATE_KEY_FILE" ]] && echo "SSH_PRIVATE_KEY_FILE environment variable should be set." && exit 1;
[[ -z "$ROLE_ARN" ]] && echo "ROLE_ARN environment variable should be set." && exit 1;
[[ -z "$ENVIRONMENT_CODE" ]] && echo "ENVIRONMENT_CODE environment variable should be set." && exit 1;

export ROLE_ARN=$ROLE_ARN
aws sts assume-role --role-arn $ROLE_ARN --role-session-name "packer_ami_build" --duration-seconds 3600 > assume-role-output.txt
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`

/opt/packer/packer build -machine-readable base-ami-amazonlinux2.json | tee build.log;
echo "$(grep 'artifact,0,id' build.log | sed 's/.*artifact,0,id,//g' | sed 's/:/ /g' | sed $'s/%!(PACKER_COMMA)/\\\n/g')" > outputs.txt;
# Show AMI Image reference
cat outputs.txt

unset AWS_SESSION_TOKEN
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
