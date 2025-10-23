pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-west-2"
        AWS_ACCOUNT_ID = "332086960978"
    }

    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Automatically apply Terraform plan without manual approval?'
        )
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/omarlouis1/terraform.git'
            }
        }

        stage('Load AWS Credentials from Jenkins') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'echo "✅ Credentials chargés depuis Jenkins."'
                }
            }
        }

        stage('Assume LabRole (Compte AWS 332086960978)') {
            steps {
                script {
                    echo "🔐 Assume Role LabRole en cours..."

                    sh """
                    aws sts assume-role \
                        --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/LabRole \
                        --role-session-name jenkinsTerraform \
                        --output json > /tmp/aws-creds.json
                    """

                    def creds = readJSON file: '/tmp/aws-creds.json'

                    env.AWS_ACCESS_KEY_ID     = creds.Credentials.AccessKeyId
                    env.AWS_SECRET_ACCESS_KEY = creds.Credentials.SecretAccessKey
                    env.AWS_SESSION_TOKEN     = creds.Credentials.SessionToken

                    echo "✅ Assume Role réussi !"
                }
            }
        }

        stage('Validate AWS Identity') {
            steps {
                sh 'aws sts get-caller-identity'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                terraform plan -out=tfplan
                terraform show -no-color tfplan > tfplan.txt
                '''
            }
        }

        stage('Manual Approval') {
            when {
                not { equals expected: true, actual: params.autoApprove }
            }
            steps {
                script {
                    def planText = readFile 'tfplan.txt'
                    input message: "Souhaites-tu appliquer le plan Terraform ?",
                          parameters: [text(name: 'Terraform Plan', defaultValue: planText)]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline terminé avec succès !"
        }
        failure {
            echo "❌ Pipeline échoué."
        }
    }
}
