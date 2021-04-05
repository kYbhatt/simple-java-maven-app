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
                    image 'maven:3_alpine'
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
                    image 'maven:3_alpine'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Application Dependency Vulnerability Analysis"
                    sh "mvn dependency-check:check -Dmaven.test.skip=true"
                    stash name: "dependency-reports", includes: "target/dependency-check-report.*"
                    archiveArtifacts artifacts: 'target/dependency-check-report.*', fingerprint: true
                }
            }
        }
        stage('Code Compile') {
            when {
                expression { env.TAG_NAME ==~ /(rc.*)|(v.*)/ || env.BRANCH_NAME == "develop" }
            }
            agent {
                docker {
                    image 'maven:3_alpine'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                	echo "Code Compile stage"
                	sh "mvn clean package -Dmaven.test.skip=true"
                	stash name: "service-jar", includes: "target/*.jar"
                }
            }
        }
    }
}
