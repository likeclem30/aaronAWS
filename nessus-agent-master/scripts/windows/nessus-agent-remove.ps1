if (!(Test-Path 'C:/Program Files/Tenable/Nessus Agent')) 
{
  echo "NOTE: Nessus Agent not installed"
  Exit $LASTEXITCOUDE
}
msiexec /x "NessusAgent-7.6.2-x64.msi" /quiet
