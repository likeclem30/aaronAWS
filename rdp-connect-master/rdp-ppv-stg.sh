ip=$(aws-vault exec ppv-npn -- aws ec2 describe-instances --filters "Name=tag:Name,Values=$2" --query  "Reservations[].Instances[].[PrivateIpAddress]" --output text)
instance_id=$(aws-vault exec ppv-npn -- aws ec2 describe-instances --filters Name=private-ip-address,Values="$ip" --query Reservations[*].Instances[*].[InstanceId] --output text)
pem_file=$(aws-vault exec ppv-npn -- aws ec2 describe-instances --filters Name=private-ip-address,Values="$ip" --query "Reservations[*].Instances[*].[KeyName]" --region us-east-1 --output text)

aws-vault exec ppv-npn -- aws ec2 get-password-data --instance-id $instance_id --priv-launch-key /Users/abhishikhtyagalla/_ssh/periscope_keys/$pem_file.pem

aws-vault exec ppv-npn -- aws ec2 get-password-data --instance-id $instance_id --priv-launch-key /Users/abhishikhtyagalla/_ssh/periscope_keys/$pem_file.pem


ssh -L 270$1:$2:3389 -i /Users/abhishikhtyagalla/_ssh/periscope_keys/ppvStgNAT.pem ec2-user@52.72.23.226
