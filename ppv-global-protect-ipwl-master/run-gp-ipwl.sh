# get the list of GPIP-Prod from the api endpoint.
echo -e "extracting the Global Protect IPs from the api."
curl -qs http://mck-ip.intranet.mckinsey.com/api/v1/external-ip | jq -r '.response[] | select(.location == "GPCS-PROD") | ."ip network" + "," + ."description"' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 > list-gp-ip.csv

echo -e "Current GlobalProtect IP count is $(wc -l list-gp-ip.csv | awk '{print $1}')."

# Split the file in part. first 198 rows will be split in xaa, 
# remaint or the second set of 198 rows will be split in xab and so on.
echo -e "\nCreating csv file IPWL"
split -l 198 list-gp-ip.csv

###echo -e "\nWhitelisting SecurityGroups in ndm-ppv-npn"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xaa sg-00ac38d9e42eb0d69 443 443
###echo -e "ppv-dev-global-protect-https-1 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xaa sg-08279c6ae72988607 22 22
###echo -e "ppv-dev-global-protect-ssh-1 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xaa sg-0f60f9e43c9dd90c0 22 22
###echo -e "ppv-stg-global-protect-ssh-1 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xaa sg-07c3a835f935f53ea 3389 3389
###echo -e "ppv-stg-global-protect-rdp-1 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xaa sg-0d06c909bacc47d6a 80 80
###echo -e "ppv-dev-global-protect-http-1 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xab sg-05ccfb8af33cb7bbc 443 443
###echo -e "ppv-dev-global-protect-https-2 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xab sg-0c0802029bedcd68a 22 22
###echo -e "ppv-dev-global-protect-ssh-2 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xab sg-0b32da141c15e78e0 22 22
###echo -e "ppv-stg-global-protect-ssh-2 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xab sg-0b3a9f93f44556303 3389 3389
###echo -e "ppv-stg-global-protect-rdp-2 ---- Done"
###aws-vault exec ppv-npn -- python3 gp-ipwl.py xab sg-020c04969fbc00d2b 80 80
###echo -e "ppv-dev-global-protect-http-2 ---- Done"
###echo -e "\n             ######\nWhitelisting completed in ndm-ppv-npn"


###echo -e "\nWhitelisting SecurityGroups in ndm-ppa-npn"
###aws-vault exec ppa-npn -- python3 gp-ipwl.py xaa sg-0c763b8997595bc35 0 65535
###echo -e "ppa-dev-global-protect-ALL-1 ---- Done"
###aws-vault exec ppa-npn -- python3 gp-ipwl.py xab sg-03489e2565a2ae2f4 0 65535
###echo -e "ppa-dev-global-protect-ALL-2 ---- Done"
###echo -e "\n             ######\nWhitelisting completed in ndm-ppa-npn"



###echo -e "\nWhitelisting SecurityGroups in psh-npn"
###aws-vault exec psh-npn -- python3 gp-ipwl.py xaa sg-0994d66e9f2fb4a62 22 22
###echo -e "psh-npn-global-protect-ssh-1 ---- Done"
###aws-vault exec psh-npn -- python3 gp-ipwl.py xab sg-076972d4df4fd12da 22 22
###echo -e "psh-npn-global-protect-ssh-2 ---- Done"
###aws-vault exec psh-npn -- python3 gp-ipwl.py xaa sg-008545db74999e3ab 443 443
###echo -e "psh-npn-global-protect-https-1 ---- Done"
###aws-vault exec psh-npn -- python3 gp-ipwl.py xab sg-033d7fb80ca2b943d 443 443
###echo -e "psh-npn-global-protect-https-2 ---- Done"
###echo -e "\n             ######\nWhitelisting completed in ndm-psh-npn"




###echo -e "\nWhitelisting SecurityGroups in ndm-ppv"
###aws-vault exec ndm-ppv -- python3 gp-ipwl.py xaa sg-05fe9bc30c4e4a76f 22 22
###echo -e "ppv-con-global-protect-ssh-1 ---- Done"
###aws-vault exec ndm-ppv -- python3 gp-ipwl.py xab sg-09e955de787e6b1e9 22 22
###echo -e "ppv-con-global-protect-ssh-2 ---- Done"
###aws-vault exec ndm-ppv -- python3 gp-ipwl.py xaa sg-0b69a33a860dcbe4b 3389 3389
###echo -e "ppv-con-global-protect-rdp-1 ---- Done"
###aws-vault exec ndm-ppv -- python3 gp-ipwl.py xab sg-079ba5443d0cf2b18 3389 3389
###echo -e "ppv-con-global-protect-rdp-2 ---- Done"
###echo -e "\n             ######\nWhitelisting completed in ndm-ppv"



###echo -e "\nWhitelisting SecurityGroups in ndm-psh"
###aws-vault exec ndm-psh -- python3 gp-ipwl.py xaa sg-0aae2d82f98aac70a 22 22
###echo -e "psh-con-global-protect-ssh-1 ---- Done"
###aws-vault exec ndm-psh -- python3 gp-ipwl.py xab sg-079f5ae5b0a369d0a 22 22
###echo -e "psh-con-global-protect-ssh-2 ---- Done"
###aws-vault exec ndm-psh -- python3 gp-ipwl.py xaa sg-03a2229e6dfe94e9c 443 443
###echo -e "psh-con-global-protect-https-1 ---- Done"
###aws-vault exec ndm-psh -- python3 gp-ipwl.py xab sg-0d0c3d298ac3aa665 443 443
###echo -e "psh-con-global-protect-https-2 ---- Done"
###echo -e "\n             ######\nWhitelisting completed in ndm-psh"

###echo -e "\nWhitelisting SecurityGroups in ndm-las-prod"
###aws-vault exec ndm-las-prod -- python3 gp-ipwl.py xaa sg-074445f289c7fb1c0 3389 3389
###echo -e "sgi-podm-con-vpc-gp-rdp1 ---- Done"
###aws-vault exec ndm-las-prod -- python3 gp-ipwl.py xab sg-0ea1284c3712b79d8 3389 3389
###echo -e "sgi-podm-con-vpc-gp-rdp2 ---- Done"
###aws-vault exec ndm-las-prod -- python3 gp-ipwl.py xaa sg-0f04c857d8da0e6b5 3389 3389
###echo -e "sgi-petl-con-vpc-gp-rdp1 ---- Done"
###aws-vault exec ndm-las-prod -- python3 gp-ipwl.py xab sg-06e965563a6ef64ab 3389 3389
###echo -e "sgi-petl-con-vpc-gp-rdp2 ---- Done"
###echo -e "\n             ######\nWhitelisting completed in ndm-las-prod"




rm -rf list-gp-ip.csv
rm -rf xaa xab