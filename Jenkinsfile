pipeline {
    agent { label 'slave node' } // Replace 'slave-node' with the actual label of your slave
    
    stages {
      stage('Checkout') {
    steps {
        git credentialsId: 'github-credentials', url: 'https://github.com/aishwaryayaya-java/new_chatapp-private.git'
    }
}



        stage('Sync Files to VM') {
            steps {
                sh 'rsync -avz $WORKSPACE/ chat_app@10.0.0.165:/tmp/demo/'
            }
        }

        stage('Copy Files to Project Directory') {
            steps {
                sh "ssh chat_app@10.0.0.165 'cp -rfv /tmp/demo/* /home/azureuser/new_chatapp/'"
            }
        }

        stage('Setup Python Environment') {
            steps {
                sh "ssh chat_app@10.0.0.165 'source /home/azureuser/myenv/bin/activate && pip install django'"
            }
        }

        stage('Install Project Requirements') {
            steps {
                sh "ssh chat_app@10.0.0.165 'source /home/azureuser/myenv/bin/activate && cd /home/azureuser/new_chatapp && pip install -r requirements.txt'"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQube') {
                    sh '''
                        /opt/sonar-scanner/bin/sonar-scanner \
                            -Dsonar.projectKey=new_chatapp \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://20.51.185.208:9000 \
                            -Dsonar.login=sqa_688f98e410dd92d4a49a5a5d6d397af5789a3eec
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status != 'OK') {
                        error "Pipeline failed due to not meeting the quality gate. Status: ${qualityGate.status}"
                    }
                }
            }
        }

        stage('Run Django Migrations') {
            steps {
                sh "ssh chat_app@10.0.0.165 'source /home/azureuser/myenv/bin/activate && cd /home/azureuser/new_chatapp/fundoo && python manage.py migrate'"
            }
        }

        stage('Restart Application Service') {
            steps {
                sh '''
                    ssh chat_app@10.0.0.165 'sudo systemctl restart new_chatapp'
                    ssh chat_app@10.0.0.165 'sudo systemctl status new_chatapp'
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the logs for more details.'
        }
    }
}

