#!/bin/bash


aws sts assume-role --role-arn arn:aws:iam::$ndm_ppv_npn:role/ppv_svcrole_chef_provisioning --role-session-name "packer_ami_build" --duration-seconds 3600 > assume-role-output.txt
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`


# Displays the count of IP addresses present in the file.
echo -e "Current GlobalProtect IP count is $(wc -l list-gp-ip.csv | awk '{print $1}')."

# Split the file in part. first 198 rows will be split in xaa, 
# remaint or the second set of 198 rows will be split in xab and so on.
echo -e "\nCreating csv file IPWL"
split -l 198 list-gp-ip.csv

echo -e "\nWhitelisting SecurityGroups in ndm-ppv-npn"
python3 gp-ipwl.py xaa sg-00ac38d9e42eb0d69 443 443
echo -e "ppv-dev-global-protect-https-1 ---- Done"
python3 gp-ipwl.py xaa sg-08279c6ae72988607 22 22
echo -e "ppv-dev-global-protect-ssh-1 ---- Done"
python3 gp-ipwl.py xaa sg-0f60f9e43c9dd90c0 22 22
echo -e "ppv-stg-global-protect-ssh-1 ---- Done"
python3 gp-ipwl.py xaa sg-07c3a835f935f53ea 3389 3389
echo -e "ppv-stg-global-protect-rdp-1 ---- Done"
python3 gp-ipwl.py xaa sg-0d06c909bacc47d6a 80 80
echo -e "ppv-dev-global-protect-http-1 ---- Done"
python3 gp-ipwl.py xab sg-05ccfb8af33cb7bbc 443 443
echo -e "ppv-dev-global-protect-https-2 ---- Done"
python3 gp-ipwl.py xab sg-0c0802029bedcd68a 22 22
echo -e "ppv-dev-global-protect-ssh-2 ---- Done"
python3 gp-ipwl.py xab sg-0b32da141c15e78e0 22 22
echo -e "ppv-stg-global-protect-ssh-2 ---- Done"
python3 gp-ipwl.py xab sg-0b3a9f93f44556303 3389 3389
echo -e "ppv-stg-global-protect-rdp-2 ---- Done"
python3 gp-ipwl.py xab sg-020c04969fbc00d2b 80 80
echo -e "ppv-dev-global-protect-http-2 ---- Done"
echo -e "\n             ######\nWhitelisting completed in ndm-ppv-npn"


rm -rf xaa xab
rm -rf assume-role-output.txt