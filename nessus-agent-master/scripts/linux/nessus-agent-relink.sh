#!/bin/bash

[ ! -f /opt/nessus_agent/sbin/nessuscli ] && echo "NOTE: Nessus Agent not installed" && exit 0
AGENT_STATUS=`sudo /opt/nessus_agent/sbin/nessuscli agent status | grep -ci "not linked"`
[ "$AGENT_STATUS" -eq "0" ]] && echo "NOTE: Nessus Agent already linked" # && exit 0

[ ! -f /usr/bin/aws ] && echo "WARNING: AWS CLI is not installed" && exit 1
INSTANCE_ID="`wget -qO- http://169.254.169.254/latest/meta-data/instance-id`"
INSTANCE_REGION="`wget -qO- http://169.254.169.254/latest/meta-data/placement/availability-zone  | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

ASG_TAG="aws:autoscaling:groupName"
ASG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$ASG_TAG" --region $INSTANCE_REGION --output=text  | cut -f5`"
[ ! -z "$ASG_VALUE" ] && echo "NOTE: ASG: EC2 instance is member of an auto scaling group" && exit 0

NAME_TAG="Name"
NAME_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$NAME_TAG" --region $INSTANCE_REGION --output=text | cut -f5`"
[ -z "$NAME_VALUE" ] && echo "WARNING: TAG: Name: Value not set" && exit 1

GROUP_TAG="Tenant"
GROUP_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$GROUP_TAG" --region $INSTANCE_REGION --output=text | cut -f5`"
[ -z "$GROUP_VALUE" ] && echo "WARNING: TAG: Tenant: Value not set" && exit 1

LINK_GROUP=$GROUP_VALUE$LINK_GROUP
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=$LINK_KEY --name=$NAME_VALUE --groups=$LINK_GROUP --cloud
