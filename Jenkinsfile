pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-west-2"
    }

    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Apply Terraform automatically without manual approval?'
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

        stage('Assume AWS LabRole') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        echo "🔐 Assume Role LabRole en cours..."

                        sh """
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

                        aws sts assume-role \
                            --role-arn arn:aws:iam::332086960978:role/LabRole \
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

        stage('Clean S3 State if Exists') {
            steps {
                sh '''
                    terraform state rm aws_s3_bucket.my_bucket || echo "✔ No S3 bucket in state, skipping."
                '''
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
                    input message: "Do you want to apply this Terraform plan?",
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
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "✅ Build réussi pour ${env.JOB_NAME} #${env.BUILD_NUMBER}\n🔗 Détails: ${env.BUILD_URL}",
                to: "omzokao99@gmail.com"
            )
        }
        failure {
            echo "❌ Pipeline échoué."
            emailext(
                subject: "❌ FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "💥 Le pipeline a échoué.\nDétails : ${env.BUILD_URL}",
                to: "omzokao99@gmail.com"
            )
        }
    }
}
