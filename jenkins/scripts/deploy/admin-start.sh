#!/bin/bash

# Start admin
cd
nohup java -jar poc/pocadmin.jar > output.txt 2>&1 &
echo "done"
exit 0;
