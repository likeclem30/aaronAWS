#!/usr/bin/python3
import boto3
import csv
import sys

security_group_id = (sys.argv[2])
port_range_start = int(sys.argv[3])
port_range_end = int(sys.argv[4])
protocol = "tcp"
csv_file = (sys.argv[1])
ec2 = boto3.resource('ec2')
security_group = ec2.SecurityGroup(security_group_id)
f = open(csv_file)
csv_f = csv.reader(f)
security_group.revoke_ingress(IpPermissions=security_group.ip_permissions) #use this to remove all rules from the group
for row in csv_f:
    cidr = row[0] + "/32"
    description = row[1]
    security_group.authorize_ingress(
        DryRun=False,
        IpPermissions=[
            {
                'FromPort': port_range_start,
                'ToPort': port_range_end,
                'IpProtocol': protocol,
                'IpRanges': [
                    {
                        'CidrIp': cidr,
                        'Description': description
                    },
                ]
            }
        ]
    )