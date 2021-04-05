Pipeline {

    agent any
    environment {
        SERVICE_NAME='sampleapp-java'




    }

    stages{
        stage('Lint Dockerfile') {
            agent {
                docker  {
                    image 'hadolint/hadolint:latest'
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    sh '''
                            hadolint Dockerfile
                    '''
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
                    sh "mvn test -Dmaven.test.skip=true"
                }
            }
        }
        stage('Dependency Vulnerability Analysis') {
            agent {
                docker {
                    image 'maven:3.6.3'
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
        stage('Sonarqube Analysis') {
            when {
                branch 'develop'
            }
            agent {
                docker {
                    image 'maven:3.6.3'
                    args '-v $HOME/.m2:/root/.m2 --entrypoint='
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Sonar Scan"
                	unstash "dependency-reports"
                	sh '''
                	    mvn clean install -Dmaven.test.skip=true
                	    mvn sonar:sonar -Dmaven.test.skip=true \
                    	    -Dsonar.projectKey=sonar_service \
                    		-Dsonar.host.url=${SONAR_HOST_URL} \
                    		-Dsonar.login=${SONARSERVICE_SONARQUBE_TOKEN} \
                    		-Dsonar.dependencyCheck.jsonReportPath=target/dependency-check-report.json \
                    		-Dsonar.dependencyCheck.xmlReportPath=target/dependency-check-report.xml \
                    		-Dsonar.dependencyCheck.htmlReportPath=target/dependency-check-report.html \
                    		-Dsonar.dependencyCheck.severity.blocker=9.0 \
                    		-Dsonar.dependencyCheck.severity.critical=7.0 \
                    		-Dsonar.dependencyCheck.severity.major=4.0 \
                    		-Dsonar.dependencyCheck.severity.minor=0.0
                	'''
                }
            }
        }
        stage('Code Compile') {
            when {
                expression { env.TAG_NAME ==~ /(rc.*)|(v.*)/ || env.BRANCH_NAME == "develop" }
            }
            agent {
                docker {
                    image 'maven:3.6.3'
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
        stage('Docker Build') {
            when {
                branch 'develop'
            }
            agent {
                docker {
                image 'docker:19.03.6'
                }
            }
            steps {
                script {
                    FAILED_STAGE=env.STAGE_NAME
                    echo "Docker image build"
                    unstash "service-jar"
                    sh'''
                    	docker build -t ${SERVICE_NAME}:latest .
                    '''
                }
            }
        }



    }
        



}
