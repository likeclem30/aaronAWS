ip=$(aws-vault exec ndm-ppv -- aws ec2 describe-instances --filters "Name=tag:Name,Values=$2" --query  "Reservations[].Instances[].[PrivateIpAddress]" --output text)
instance_id=$(aws-vault exec ndm-ppv -- aws ec2 describe-instances --filters Name=private-ip-address,Values="$ip" --query Reservations[*].Instances[*].[InstanceId] --output text)
pem_file=$(aws-vault exec ndm-ppv -- aws ec2 describe-instances --filters Name=private-ip-address,Values="$ip" --query "Reservations[*].Instances[*].[KeyName]" --region us-east-1 --output text)

aws-vault exec ndm-ppv -- aws ec2 get-password-data --instance-id $instance_id --priv-launch-key /Users/abhishikhtyagalla/_ssh/periscope_keys/$pem_file.pem

ssh -L 230$1:$ip:3389 -i /Users/abhishikhtyagalla/_ssh/periscope_keys/ppvNAT.pem ec2-user@52.1.241.36
