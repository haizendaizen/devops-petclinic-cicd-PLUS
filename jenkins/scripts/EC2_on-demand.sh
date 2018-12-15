#!/bin/bash

# Script parameters

# imageid="ami-a0cfeed8" # Amazon Linux AMI 2018.03.0 (HVM)
# instance_type="t2.micro"
# key_name="MyKeyPair"
# sec_group_TCP="sg-09238c50b5c5aa1c6"
# sec_group_8080="sg-0d04e3cac0e005a8d"
# wait_seconds="60" # seconds between polls for the public IP to populate (keeps it from hammering their API)
key_location="/home/leonux/aws/MyKeyPair.pem" # SSH settings
# user="ec2-user" # SSH settings
# jar_file="target/*.jar" # SSH settings
# deploy_scripts="jenkins/scripts/deploy/*.sh" # SSH settings


# private
connect ()
{
        # ssh -oStrictHostKeyChecking=no -i $key_location $user@$AWS_IP mkdir poc
        ansible all -i hosts -u ec2-user --private-key=$key_location -b -a "mkdir poc"
}

# private
publish ()
{
        ansible all -i hosts -u ec2-user --private-key=$key_location -b -m copy -a "src=hosts dest=~/hosts"
        ansible-playbook jenkins/scripts/ansible/copyfile.yml -i hosts --private-key=$key_location

        ansible-playbook jenkins/scripts/ansible/copy_chef_files.yml -i httpd --private-key=$key_location
}

# private
configEnv ()
{
        # Configure EC2 nodes
        ansible all -i hosts -u ec2-user --private-key=$key_location -b -a "yum -y update"
        ansible-playbook jenkins/scripts/ansible/configEC2.yml -i hosts --private-key=$key_location

        # Configure NGINX webserver ansible all -i httpd -u ec2-user --private-key=$key_location -b -a "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable -v 2.5.3"
        #Step 1: Install CHEF via SSH
        echo "Step 1: Install CHEF via SSH"
        ssh -oStrictHostKeyChecking=no -i $key_location ec2-user@$(cat httpd) "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable -v 2.5.3"
        sleep 30

        #Step 2: Configure CHEF run environment
        ansible all -i httpd -u ec2-user --private-key=$key_location -b -a "mkdir chef-repo"
        ansible all -i httpd -u ec2-user --private-key=$key_location -b -a "mkdir chef-repo/cookbooks"

        #Step 3: Generate NGINX cookbook
        ansible all -i httpd -u ec2-user --private-key=$key_location -b -a "cd chef-repo/ && chef generate cookbook cookbooks/nginx_setup"

        #Step 4: Create template
        ansible all -i httpd -u ec2-user --private-key=$key_location -b -a "cd chef-repo/ && chef generate template cookbooks/nginx_setup nginx.conf"
}

# private
# getip ()
# {
# 	AWS_IP=$(~/.local/bin/aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
# }

# public
start ()
{
	echo "Starting instance..."

	# id=$(~/.local/bin/aws ec2 run-instances --image-id $imageid --count 1 --instance-type $instance_type --key-name $key_name --security-group-ids $sec_group_TCP $sec_group_8080 --query 'Instances[0].InstanceId' | grep -E -o "i\-[0-9A-Za-z]+")

	# INSTANCE_ID=$id

	# wait for a public ip
	# while true; do

		# echo "Waiting $wait_seconds seconds for IP..."
		# sleep $wait_seconds
		# getip
		# if [ ! -z "$AWS_IP" ]; then
			# break
		# else
		# 	echo "Not found yet. Waiting for $wait_seconds more seconds."
		# 	sleep $wait_seconds
		# fi

	# done
  # Execute terraform scripts and then going back to root directory.
  cd jenkins/scripts/terraform/
  /home/leonux/terraform/bin/terraform init -input=false
  /home/leonux/terraform/bin/terraform plan -out=tfplan -input=false -var-file="/home/leonux/aws/terraform.tfvars"
  /home/leonux/terraform/bin/terraform apply -input=false tfplan
  cd ../../../
	# echo "Found IP $AWS_IP - Instance $INSTANCE_ID"

	# echo "Trying to connect... $user@$AWS_IP"

	sleep 30
	connect

    #     echo "$AWS_IP" > hosts

	echo "Config Task: Started"

	configEnv

  echo "Publish Over SSH..."

	publish

	echo "Starting NGINX..."

  ansible all -i httpd -u ec2-user --private-key=$key_location -b -a "cd chef-repo/ && sudo chef-client --local-mode --runlist 'recipe[nginx_setup::webserver]'"

  echo "Done!"

	# echo "$AWS_IP" > ip_from_file

	# echo "$INSTANCE_ID" > id_from_file

}

# public
terminate ()
{
	echo "Shutting down..."
  cd jenkins/scripts/terraform/
  /home/leonux/terraform/bin/terraform destroy  -auto-approve -var-file="/home/leonux/aws/terraform.tfvars"
	# export KILL_ID=$(cat id_from_file) && ~/.local/bin/aws ec2 terminate-instances --instance-ids $KILL_ID


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
