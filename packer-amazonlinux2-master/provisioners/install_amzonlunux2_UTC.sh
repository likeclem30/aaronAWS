#!/usr/bin/env bash

set -e

function run_as_root() {
	function log_text() {
		local log_level="$1";
		local log_message="$2";
		local echo_argument="$3";
		local datepart=$(date +"%d-%m-%Y %H:%M:%S,%3N");
		echo $echo_argument "[$datepart] [`hostname`] [$log_level] [`whoami`] $log_message";
	}

	function log_info() {
		log_text "INFO " "$1";
	}

	function update_system() {
		log_info "Updating system";
		sudo yum update -y;
		sudo yum remove yum-plugin-priorities -y
		sudo rm -rf /var/cache/yum;
	}

	function install_tools() {
		log_info "Installing tools.";
		yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		yum install -y unzip zip wget tcpdump htop bash-completion telnet;
		wget "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
		chmod +x ./jq-linux64; 
		mv jq-linux64 /usr/bin/jq;
		sudo yum update -y;
		sudo rm -rf /var/cache/yum;
		}

	function install_inspector() {
		log_info "Downloading Inspector";
		wget https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install -O AWSInspector.sh
		log_info "Installing Inspector";
		bash AWSInspector.sh
		rm -f AWSInspector.sh 
		}

	function install_nessusAgent_amazon() {
		log_info "Downloading Nessus Agent";
		wget -O NessusAgent.rmp https://ndm-mash-test-npn-common.s3.amazonaws.com/nessus/installers/NessusAgent-7.6.2-amzn.x86_64.rpm
		log_info "Installing Nessus Agent for Tenable";
		sudo rpm -ivh NessusAgent.rmp
		sudo /sbin/chkconfig nessusagent on
		rm -rf  NessusAgent.rmp
		}

## SSM is pre installed on Amazon Linux 2.

    function set_timezone() {
        log_info "Setting timezone to UTC";
        sudo timedatectl set-timezone UTC
        log_info "setting timezone to UTC done";       
    }

	function remove_tempfiles() {
		echo ">>> Cleaning up SSH host keys"
		shred -u /etc/ssh/*_key /etc/ssh/*_key.pub;
		
		echo ">>> Cleaning up accounting files"
		rm -f /var/run/utmp
		>/var/log/lastlog
		>/var/log/wtmp
		>/var/log/btmp

		echo ">>> Remove temporary files"
		rm -rf /tmp/* /var/tmp/*;

		echo ">>> Remove history"
		unset HISTFILE;
		rm -rf /home/*/.*history /root/.*history;

		# Make sure we wait until all the data is written to disk, otherwise
		# Packer might quite too early before the large files are deleted
		sync
	}

	function install_python() {
			 log_info "Installing python"
			 yum install -y gcc openssl-devel bzip2-devel libffi libffi-devel;
			 sudo yum install python3 -y
		 }

	function run_all() {
		update_system;
		install_tools;
        install_inspector;
		install_nessusAgent_amazon;
	    set_timezone;
		remove_tempfiles;
		install_python;
		log_info "Done.";
	}
	
	run_all;
}

FUNC=$(declare -f run_as_root);
sudo bash -c "$FUNC; run_as_root";
