#!/bin/bash


aws sts assume-role --role-arn arn:aws:iam::$ndm_ppv:role/ppv_svcrole_chef_provisioning --role-session-name "packer_ami_build" --duration-seconds 3600 > assume-role-output.txt
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`


# Displays the count of IP addresses present in the file.
echo -e "Current GlobalProtect IP count is $(wc -l list-gp-ip.csv | awk '{print $1}')."

# Split the file in part. first 198 rows will be split in xaa, 
# remaint or the second set of 198 rows will be split in xab and so on.
echo -e "\nCreating csv file IPWL"
split -l 198 list-gp-ip.csv

echo -e "\nWhitelisting SecurityGroups in ndm-ppv"
python3 gp-ipwl.py xaa sg-05fe9bc30c4e4a76f 22 22
echo -e "ppv-con-global-protect-ssh-1 ---- Done"
python3 gp-ipwl.py xab sg-09e955de787e6b1e9 22 22
echo -e "ppv-con-global-protect-ssh-2 ---- Done"
python3 gp-ipwl.py xaa sg-0b69a33a860dcbe4b 3389 3389
echo -e "ppv-con-global-protect-rdp-1 ---- Done"
python3 gp-ipwl.py xab sg-079ba5443d0cf2b18 3389 3389
echo -e "ppv-con-global-protect-rdp-2 ---- Done"
echo -e "\n             ######\nWhitelisting completed in ndm-ppv"


rm -rf xaa xab
rm -rf assume-role-output.txt