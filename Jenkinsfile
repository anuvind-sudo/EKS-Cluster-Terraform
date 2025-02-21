pipeline {
    agent any

    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: ['apply', 'destroy', 'plan'], description: 'Select Terraform action to perform')
        string(name: 'USER_NAME', defaultValue: 'Admin', description: 'Specify who is running the code')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
        TF_VAR_aws_region     = 'ap-south-1'
    }

    stages {
        stage('Checkout Version Control') {
            steps {
                dir('terraform') {
                    checkout scmGit(
                        branches: [[name: '*/main']],
                        extensions: [],
                        userRemoteConfigs: [[credentialsId: 'githubintergation', url: 'https://github.com/anuvind-sudo/EKS-Cluster-Terraform.git']]
                    )
                }
            }
        }

        stage('Terraform Initialization') {
            steps {
                dir('terraform') {
                    withCredentials([string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'), 
                                     string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Action Selector') {
            steps {
                dir('terraform') {
                    script {
                        switch (params.TERRAFORM_ACTION) {
                            case 'apply':
                                sh 'terraform apply -auto-approve'
                                break
                            case 'destroy':
                                sh 'terraform destroy -auto-approve'
                                break
                            case 'plan':
                                sh 'terraform plan'
                                break
                            default:
                                error "Invalid Terraform action selected: ${params.TERRAFORM_ACTION}"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // Wrap cleanup in node block to ensure workspace context is available
            node {
                cleanWs()
            }
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
}
