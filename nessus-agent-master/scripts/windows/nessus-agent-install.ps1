if (!(Test-Path 'C:/Program Files/Amazon/AWSCLI*')) 
{
  Write-Warning "AWS CLI is not installed"
  Exit $LASTEXITCOUDE
}

$INSTANCE_ID=Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/instance-id
$INSTANCE_REGION=Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/placement/availability-zone
$INSTANCE_REGION=$INSTANCE_REGION.Substring(0,$INSTANCE_REGION.Length-1)

$ASG_TAG="aws:autoscaling:groupName"
$ASG_VALUE=(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$ASG_TAG" --region $INSTANCE_REGION --output=text).split()[4]
if ($ASG_VALUE -ne "" -and $ASG_VALUE -ne $null)
{
   echo "NOTE: ASG: EC2 instance is member of an auto scaling group"
   Exit $LASTEXITCODE
}

$NAME_TAG="Name"
$NAME_VALUE=(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$NAME_TAG" --region $INSTANCE_REGION --output=text).split()[4]
if ($NAME_VALUE -eq "" -or $NAME_VALUE -eq $null) 
{
  Write-Warning "TAG: Name: Value not set"
  Exit $LASTEXITCOUDE
}

$GROUP_TAG="Tenant"
$GROUP_VALUE=(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$GROUP_TAG" --region $INSTANCE_REGION --output=text).split()[4]
if ($GROUP_VALUE -eq "" -or $GROUP_VALUE -eq $null) 
{
  Write-Warning "Tag: Tenant: Value not set"
  Exit $LASTEXITCOUDE
}
$LINK_GROUP=$GROUP_VALUE+$LINK_GROUP
msiexec /i "NessusAgent-7.6.2-x64.msi" NESSUS_KEY=$LINK_KEY NESSUS_NAME=$NAME_VALUE NESSUS_GROUPS=$LINK_GROUP NESSUS_SERVER="cloud.tenable.com:443" /qn 
