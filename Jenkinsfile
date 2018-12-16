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

                input message: 'Deploy? (Click "Proceed" to continue)'
                sh 'echo "Deployment Task: Started"'
                sh 'ansible all -i hosts -u ec2-user --private-key=/home/leonux/aws/MyKeyPair.pem -b -a "./deploy.sh"'
                sleep(time:20,unit:"SECONDS")

                sh 'echo "NGINX Setup Task: Started"'
                sh './jenkins/scripts/nginx_setup.sh'
                sleep(time:20,unit:"SECONDS")
                sh 'export IP=$(cat httpd) && echo "Your app is ready: http://$IP"'

                sh 'echo "UI tests: Started"'
                sh 'export IP=$(cat httpd) && cd ./src/test/selenium/ && ./gradlew -Dbase.url=http://$IP -DbrowserType=htmlunit test'
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

                input message: 'Deploy? (Click "Proceed" to continue)'
                sh 'echo "Deployment Task: Started"'
                sh 'ansible all -i hosts -u ec2-user --private-key=/home/leonux/aws/MyKeyPair.pem -b -a "./deploy.sh"'
	              sleep(time:20,unit:"SECONDS")

                sh 'echo "NGINX Setup Task: Started"'
                sh './jenkins/scripts/nginx_setup.sh'
                sleep(time:20,unit:"SECONDS")
                sh 'export IP=$(cat httpd) && echo "Your app is ready: http://$IP"'

		            input message: 'Finished using the web site? (Click "Proceed" to continue)'
		            sh 'echo "Terminate Task: Started"'
		            sh './jenkins/scripts/EC2_on-demand.sh terminate'
            }
        }
    }
}
