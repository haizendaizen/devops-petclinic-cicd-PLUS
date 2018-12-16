#!/bin/bash

# Script parameters

# imageid="ami-a0cfeed8" # Amazon Linux AMI 2018.03.0 (HVM)
# instance_type="t2.micro"
# key_name="MyKeyPair"
key_location="/home/leonux/aws/MyKeyPair.pem" # SSH settings
user="ec2-user" # SSH settings

# private
connect ()
{
        ansible all -i hosts -u $user --private-key=$key_location -b -a "mkdir poc"
}

# private
publish ()
{
        ansible all -i hosts -u $user --private-key=$key_location -b -m copy -a "src=hosts dest=~/hosts"
        ansible-playbook jenkins/scripts/ansible/copyfile.yml -i hosts --private-key=$key_location

        ansible-playbook jenkins/scripts/ansible/copy_chef_files.yml -i httpd --private-key=$key_location
}

# private
configEnv ()
{
        # Configure EC2 nodes
        ansible all -i hosts -u $user --private-key=$key_location -b -a "yum -y update"
        ansible-playbook jenkins/scripts/ansible/configEC2.yml -i hosts --private-key=$key_location

        # Configure NGINX webserver
        #Step 1: Install CHEF via SSH... Note: multicommands doesn't work properly in Ansible. Better to create them in a Playbook. Use SSH for simplicity.
        echo "Step 1: Install CHEF via SSH"
        ssh -oStrictHostKeyChecking=no -i $key_location $user@$(cat httpd) "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable -v 2.5.3"
        sleep 30

        #Step 2: Configure CHEF run environment
        ansible all -i httpd -u $user --private-key=$key_location -b -a "mkdir chef-repo"
        ansible all -i httpd -u $user --private-key=$key_location -b -a "mkdir chef-repo/cookbooks"

        #Step 3: Generate NGINX cookbook
        ansible all -i httpd -u $user --private-key=$key_location -b -a "chef generate cookbook chef-repo/cookbooks/nginx_setup"

        #Step 4: Create template
        ansible all -i httpd -u $user --private-key=$key_location -b -a "chef generate template chef-repo/cookbooks/nginx_setup nginx.conf"
}

# public
start ()
{
	echo "Starting instance..."

  # Execute terraform scripts and then going back to root directory.
  cd jenkins/scripts/terraform/
  /home/leonux/terraform/bin/terraform init -input=false
  /home/leonux/terraform/bin/terraform plan -out=tfplan -input=false -var-file="/home/leonux/aws/terraform.tfvars"
  /home/leonux/terraform/bin/terraform apply -input=false tfplan
  cd ../../../
	# done!

  # Give some time for Infrastructure to provision, then test and connect.
	sleep 30
	connect

	echo "Config Task: Started"
	configEnv

  echo "Publish Over SSH..."
	publish

	echo "Installing NGINX..."
  ssh -oStrictHostKeyChecking=no -i $key_location $user@$(cat httpd) "cd chef-repo/ && sudo chef-client --local-mode --runlist 'recipe[nginx_setup::webserver]'"

  echo "Done!"
}

# public
terminate ()
{
	echo "Shutting down..."
  cd jenkins/scripts/terraform/
  /home/leonux/terraform/bin/terraform destroy  -auto-approve -var-file="/home/leonux/aws/terraform.tfvars"
}

# public
instruct ()
{
	echo "Please provide an argument: start, terminate"
}

#-------------------------------------------------------

# "main"
case "$1" in
	start)
		start
		;;
	terminate)
		terminate
		;;
	help|*)
		instruct
		;;
esac
