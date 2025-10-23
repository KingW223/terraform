pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_SESSION_TOKEN     = credentials('AWS_SESSION_TOKEN')  // si credentials temporaires
        AWS_DEFAULT_REGION    = "us-west-2"
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

        stage('Validate AWS Credentials') {
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
                    input message: "Do you want to apply the Terraform plan?",
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
                body: """
                ✅ Build réussi pour ${env.JOB_NAME} #${env.BUILD_NUMBER}
                🔗 Détails: ${env.BUILD_URL}
                """,
                to: "omzokao99@gmail.com"
            )
        }
        failure {
            echo "❌ Échec du pipeline."
            emailext(
                subject: "❌ FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué 💥\n\nDétails : ${env.BUILD_URL}",
                to: "omzokao99@gmail.com"
            )
        }
    }
}
   
