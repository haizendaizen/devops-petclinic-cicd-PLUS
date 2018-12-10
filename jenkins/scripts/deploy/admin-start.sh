#!/bin/bash

# Start admin
cd
nohup java -jar /home/ec2-user/poc/pocadmin.jar > output.txt 2>&1 &
echo "done"
exit 0;
