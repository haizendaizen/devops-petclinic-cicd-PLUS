#!/bin/bash

setEnv(){
        cd /home/ec2-user/poc/
        mv spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar ./pocadmin.jar
}

startApp(){
        echo "[poc-deploy] starting application"
        cd
        /home/ec2-user/admin-start.sh
}

run(){
        echo "[poc-deploy]"

        setEnv
        startApp
}

run

exit 0;
