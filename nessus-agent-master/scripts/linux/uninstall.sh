#!/bin/bash

[ ! -f /opt/nessus_agent/sbin/nessuscli ] && echo "NOTE: Nessus Agent not installed" && exit 0
. ./tenableio.sh
. ./nessus-agent-remove.sh
