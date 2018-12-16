pipeline {
    agent any
    stages {
  	     stage('Build') {
	            steps {
	            	sh './mvnw package'
                        junit 'target/surefire-reports/*.xml'
            }
        }
	    stage('Deliver for DEV') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'echo "AWS Provisioning Task: Started"'
		            sh './jenkins/scripts/EC2_on-demand.sh start'
                sh 'export IP=$(cat ip_from_file) && ssh -oStrictHostKeyChecking=no -i /home/leonux/aws/MyKeyPair.pem ec2-user@$IP ./deploy.sh'

                sleep(time:20,unit:"SECONDS")
	              sh 'export IP=$(cat ip_from_file) && echo "Your app is ready: http://$IP:8080"'

                sh 'echo "UI tests: Started"'
                sh 'export IP=$(cat ip_from_file) && cd ./src/test/selenium/ && ./gradlew -Dbase.url=http://$IP:8080 -DbrowserType=htmlunit test'
                publishHTML (target: [
                reportDir: './src/test/selenium/build/reports/tests/test',
                reportFiles: 'index.html',
                reportName: "UI tests report"
                ])

		input message: 'Finished using the web site? (Click "Proceed" to continue)'
		sh 'echo "Terminate Task: Started"'
		sh './jenkins/scripts/EC2_on-demand.sh terminate'
            }
        }
            stage('Deploy to PROD') {
            when {
                branch 'master'
            }
            steps {
	              sh 'echo "AWS Provisioning Task: Started"'
		            sh './jenkins/scripts/EC2_on-demand.sh start'
                sleep(time:20,unit:"SECONDS")

                sh 'echo "Deployment Task: Started"'
                sh 'ansible all -i hosts -u ec2-user --private-key=/home/leonux/aws/MyKeyPair.pem -b -a "./deploy.sh"'
	              sleep(time:20,unit:"SECONDS")

                sh 'echo "NGINX Setup Task: Started"'
                sh './jenkins/scripts/nginx_setup.sh'
                sleep(time:20,unit:"SECONDS")
                sh 'export IP=$(cat httpd) && echo "Your app is ready: http://$IP:9000"'

		            input message: 'Finished using the web site? (Click "Proceed" to continue)'
		            sh 'echo "Terminate Task: Started"'
		            sh './jenkins/scripts/EC2_on-demand.sh terminate'
            }
        }
    }
}
