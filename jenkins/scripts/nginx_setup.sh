#!/bin/bash

getip ()
{
	cd jenkins/scripts/terraform/
	IP_nodeA=$(/home/leonux/terraform/bin/terraform output IP-nodeA")
	IP_nodeB=$(/home/leonux/terraform/bin/terraform output IP-nodeB")
}

run ()
{
  echo "[Find & Replace]"
	getip
	cd ../../../
	pwd
	ssh -oStrictHostKeyChecking=no -i /home/leonux/aws/MyKeyPair.pem ec2-user@$(cat httpd) "sudo sed -i 's/nodeA/$IP_nodeA/g' chef-repo/cookbooks/nginx_setup/templates/nginx.conf.erb"
	ssh -oStrictHostKeyChecking=no -i /home/leonux/aws/MyKeyPair.pem ec2-user@$(cat httpd) "sudo sed -i 's/nodeA/$IP_nodeB/g' chef-repo/cookbooks/nginx_setup/templates/nginx.conf.erb"

	echo "Re-starting NGINX..."
  	ssh -oStrictHostKeyChecking=no -i /home/leonux/aws/MyKeyPair.pem ec2-user@$(cat httpd) "cd chef-repo/ && sudo chef-client --local-mode --runlist 'recipe[nginx_setup::webserver]'"

	echo "Done!"
}

run

exit 0;
