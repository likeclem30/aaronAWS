# ppv_npn_dev_elb

For New tenants add a directory with tenant code. like rc6-tenant5 and add main.tf and relavent terraform config for the load balancer.

### Terraform init.
aws-vault exec ppv-npn -- terraform init

### Terraform plan.
aws-vault exec ppv-npn -- terraform plan

### Terraform apply.
aws-vault exec ppv-npn -- terraform apply

