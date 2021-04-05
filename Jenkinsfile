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
                    image 'maven:3.6.3'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Unit Test "
                    sh "mvn clean package -Dmaven.test.skip=true"
                    stash name: "service-jar", includes: "target/*.jar"
                }
            }
        }
    }
}
