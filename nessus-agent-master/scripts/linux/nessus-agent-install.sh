#!/bin/bash

[ ! -f `which aws` ] && echo "WARNING: AWS CLI is not installed" && exit 1
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

OS_RELEASE=`sudo cat /etc/os-release`
case "$OS_RELEASE" in
   *amazon*   )
      sudo rpm -ivh NessusAgent-7.6.2-amzn.x86_64.rpm
      sudo /sbin/service nessusagent start
      ;;
   *centos*   )
      sudo yum install -y NessusAgent-7.6.2-es7.x86_64.rpm
      sudo /bin/systemctl start nessusagent.service
      ;;
   *redhat*   )
      sudo yum install -y NessusAgent-7.6.2-rh7.x86_64.rpm
      sudo /bin/systemctl start nessusagent.service
      ;;
   *ubuntu*   )
      sudo apt install ./NessusAgent-7.6.2-ubuntu1110_amd64.deb -y
      sudo /etc/init.d/nessusagent start
      ;;
   *          )
      echo "WARNING: OS release not supported"
      exit 1
esac      

LINK_GROUP=$GROUP_VALUE$LINK_GROUP
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=$LINK_KEY --name=$NAME_VALUE --groups=$LINK_GROUP --cloud
