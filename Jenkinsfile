pipeline { 
    environment { 
        registry =  'DOCKER_HUB_REPO'
        registryCredential = 'docker-id' 
        dockerImage = '' 
    }
    agent any 
    stages {
        stage('linting dockerfile') { 
            steps { 
                sh "hadolint Dockerfile" 
            }
        } 

        stage('linting python app') { 
            steps {
                sh "pip3 install --no-cache-dir -r pyapp/requirements.txt"
                sh "/var/lib/jenkins/.local/bin/pylint pyapp/app.py --errors-only" 
            }
        } 

        stage('Building our image') { 
            steps { 
                script { 
                    dockerImage = docker.build registry + ":$env.BUILD_ID" 
                }
            } 
        }

        stage('Push our image') { 
            steps { 
                script { 
                    docker.withRegistry( '', registryCredential ) { 
                        dockerImage.push() 
                    }
                } 
            }
        } 

        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $registry:$env.BUILD_ID" 
            }
        }

        stage('updating kubeconfig'){
            steps {
                withAWS(region: 'eu-central-1', credentials: 'aws-creds') {
                    sh "aws eks --region eu-central-1 update-kubeconfig --name uda-eks"
                }
            }
        }
        stage('check if kubectl working'){
            steps {
                withAWS(region: 'eu-central-1', credentials: 'aws-creds') {
                    sh "kubectl get nodes"
                }   
            }
        }
        stage('deploy app on eks'){
            steps {
                withAWS(region: 'eu-central-1', credentials: 'aws-creds') {
                    sh "kubectl run uda-pyapp --image=$registry:$env.BUILD_ID --restart=Never"
                }  
            }
        }
        stage('expose app with loadbalancer'){
            steps {
                withAWS(region: 'eu-central-1', credentials: 'aws-creds') {
                    sh "kubectl expose pod uda-pyapp --type=LoadBalancer --port=5000"
                }
            }
        }
    }
}
