#!/bin/bash

setEnv(){
        cd
        cd poc/
        mv spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar ./pocadmin.jar
}

startApp(){
        echo "[poc-deploy] starting application"
        cd
        ./admin-start.sh
}

run(){
        echo "[poc-deploy]"

        setEnv
        startApp
}

run

exit 0;
