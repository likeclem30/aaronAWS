#!/bin/bash


aws sts assume-role --role-arn arn:aws:iam::$ndm_psh:role/psh_svcrole_chef_provisioning --role-session-name "packer_ami_build" --duration-seconds 3600 > assume-role-output.txt
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`


# Displays the count of IP addresses present in the file.
echo -e "Current GlobalProtect IP count is $(wc -l list-gp-ip.csv | awk '{print $1}')."

# Split the file in part. first 198 rows will be split in xaa, 
# remaint or the second set of 198 rows will be split in xab and so on.
echo -e "\nCreating csv file IPWL"
split -l 198 list-gp-ip.csv

echo -e "\nWhitelisting SecurityGroups in ndm-psh"
python3 gp-ipwl.py xaa sg-0aae2d82f98aac70a 22 22
echo -e "psh-con-global-protect-ssh-1 ---- Done"
python3 gp-ipwl.py xab sg-079f5ae5b0a369d0a 22 22
echo -e "psh-con-global-protect-ssh-2 ---- Done"
python3 gp-ipwl.py xaa sg-03a2229e6dfe94e9c 443 443
echo -e "psh-con-global-protect-https-1 ---- Done"
python3 gp-ipwl.py xab sg-0d0c3d298ac3aa665 443 443
echo -e "psh-con-global-protect-https-2 ---- Done"
echo -e "\n             ######\nWhitelisting completed in ndm-psh"

cat list-gp-ip.csv
rm -rf xaa xab
rm -rf assume-role-output.txt