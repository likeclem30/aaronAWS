#!/bin/bash

[ ! -f /opt/nessus_agent/sbin/nessuscli ] && echo "NOTE: Nessus Agent not installed" && exit 0
sudo /opt/nessus_agent/sbin/nessuscli agent unlink

OS_RELEASE=`sudo cat /etc/os-release`
case "$OS_RELEASE" in
   *amazon*   )
      sudo /sbin/service nessusagent stop
      sudo rpm -qa | grep -i NessusAgent
      sudo rpm -ev NessusAgent-7.6.2-amzn.x86_64
      ;;
   *centos*   )
      sudo /bin/systemctl stop nessusagent.service
      sudo yum remove -y NessusAgent-7.6.2-es7.x86_64
      ;;
   *redhat*   )
      sudo /bin/systemctl stop nessusagent.service
      sudo yum remove -y NessusAgent-7.6.2-rh7.x86_64
      ;;
   *ubuntu*   )
      sudo /etc/init.d/nessusagent stop
      sudo apt remove NessusAgent-7.6.2-ubuntu1110_amd64 -y
      ;;
   *          )
      echo "WARNING: OS release not supported"
      exit 1
esac      
