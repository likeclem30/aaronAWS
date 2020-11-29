#!/bin/bash


aws sts assume-role --role-arn arn:aws:iam::$ndm_las_prod:role/las_prod_svcrole_jenkins_provisioning --role-session-name "packer_ami_build" --duration-seconds 3600 > assume-role-output.txt
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`


# Displays the count of IP addresses present in the file.
echo -e "Current GlobalProtect IP count is $(wc -l list-gp-ip.csv | awk '{print $1}')."

# Split the file in part. first 198 rows will be split in xaa, 
# remaint or the second set of 198 rows will be split in xab and so on.
echo -e "\nCreating csv file IPWL"
split -l 198 list-gp-ip.csv

echo -e "\nWhitelisting SecurityGroups in ndm-las-prod"
python3 gp-ipwl.py xaa sg-074445f289c7fb1c0 3389 3389
echo -e "sgi-podm-con-vpc-gp-rdp1 ---- Done"
python3 gp-ipwl.py xab sg-0ea1284c3712b79d8 3389 3389
echo -e "sgi-podm-con-vpc-gp-rdp2 ---- Done"
python3 gp-ipwl.py xaa sg-0f04c857d8da0e6b5 3389 3389
echo -e "sgi-petl-con-vpc-gp-rdp1 ---- Done"
python3 gp-ipwl.py xab sg-06e965563a6ef64ab 3389 3389
echo -e "sgi-petl-con-vpc-gp-rdp2 ---- Done"
echo -e "\n             ######\nWhitelisting completed in ndm-las-prod"

rm -rf xaa xab
rm -rf assume-role-output.txt