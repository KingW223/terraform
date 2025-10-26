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
            description: 'Appliquer automatiquement le plan Terraform sans approbation manuelle ?'
        )
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/KingW223/terraform.git'
            }
        }

        stage('Validate AWS Credentials') {
            steps {
                bat '''
                    echo Vérification des identifiants AWS...
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                bat '''
                    echo Initialisation de Terraform...
                    terraform init
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                bat '''
                    echo Génération du plan Terraform...
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
                    def planText = readFile('tfplan.txt')
                    input message: "Souhaitez-vous appliquer le plan Terraform ?",
                          parameters: [text(name: 'Terraform Plan', defaultValue: planText)]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                bat '''
                    echo Application du plan Terraform...
                    terraform apply -input=false tfplan
                '''
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
                🔗 Détails : ${env.BUILD_URL}
                """,
                to: "naziftelecom2@gmail.com"
            )
        }
        failure {
            echo "❌ Échec du pipeline."
            emailext(
                subject: "❌ FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué 💥\n\nDétails : ${env.BUILD_URL}",
                to: "naziftelecom2@gmail.com"
            )
        }
    }
}
