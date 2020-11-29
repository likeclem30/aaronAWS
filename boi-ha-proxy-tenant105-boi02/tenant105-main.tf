provider "aws" {
  region = "us-east-1"
}


terraform {
   backend "s3" {
     bucket         = "ndm-ppv-tfstate"
     encrypt        = true
     region         =  "us-east-1"
     key            = "tenant105-ha-proxy/boi02-t105-ha-proxy.tfstate"
   }
 }

resource "aws_network_interface" "boi02-t105-ha-proxy-networkinterface" {
  subnet_id   = "subnet-082547782c08527f3"
  security_groups = ["sg-020f2675ae82dfb92"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "boi02-t105-ha-proxy-ec2" {
  ami           = "${var.ami_id}"
  instance_type = "t3.medium"
  key_name = "ppvBoi02Isolated"
  iam_instance_profile = "ppv_srvrole_tenant105-boi02-ha-proxy"
  ebs_optimized = "true"
  disable_api_termination = "true"

  network_interface {
    network_interface_id = "${aws_network_interface.boi02-t105-ha-proxy-networkinterface.id}"
    device_index         = 0
  }

  tags = {
    Name = "ppv-boi02-isolated-haproxy-1",
    Environment = "con-tenant105",
    Solution = "Periscope",
    "Solution Name" = "Periscope",
    Tenant = "tenant105",
    patching_window = "430AMUTC",
    BackupAMIwithReboot = "yes"
  }
}

resource "aws_eip_association" "boi02-t105-ha-proxy-eip_assoc" {
  instance_id   = "${aws_instance.boi02-t105-ha-proxy-ec2.id}"
  allocation_id = "${var.elastic_IP_allocation}"
}