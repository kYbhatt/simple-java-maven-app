pipeline {

    agent any
    environment{
        SERVICE_NAME='sample-service'
    }

    stages{
        stage ("lint dockerfile") {
            agent {
                docker {
                    image 'hadolint/hadolint:latest-debian'
            //image 'ghcr.io/hadolint/hadolint:latest-debian'
                }
            }
            steps {
                sh 'hadolint Dockerfile | tee -a hadolint_lint.txt'
            }
            post {
                always {
                    archiveArtifacts 'hadolint_lint.txt'
                }
            }
        }
        stage('Unit Test') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Unit Test "
                    sh "mvn test -Dmaven.test.skip=true"
                }
            }
        }
        stage('Dependency Vulnerability Analysis') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Application Dependency Vulnerability Analysis"
                }
            }
        }
        stage('Code Compile') {
            agent {
                docker {
                   image 'maven:3-alpine'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                	echo "Code Compile stage"
                	sh "mvn clean package -Dmaven.test.skip=true"
                	stash name: "service-jar", includes: "target/*.jar"
			archiveArtifacts 'target/*.jar'
                }
            }
        }
        stage('Docker Build') {
            agent {
                docker {
                image 'docker:20.10.5'
         	args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Docker image building"
                    unstash "service-jar"
		   sh 'docker build -t $SERVICE_NAME:latest .'
                }
            }
        }
    }
}
