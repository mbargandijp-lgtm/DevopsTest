pipeline {
    agent any
    
    // La section tools est retirée car l'outil 'M3' n'était pas configuré.
    // L'agent utilise donc l'installation Maven disponible dans son PATH.

    environment {
        // Clé du projet SonarQube
        SONAR_PROJECT_KEY = 'mon-projet-devops-ci-cd'
        
        // Nom de l'identifiant secret Jenkins (doit être un token admin/créateur de projet)
        SONAR_TOKEN_CREDENTIAL_ID = 'SonarQube API Token for Jenkins CI' 
        
        // Nom du serveur SonarQube configuré dans Gérer Jenkins -> Configurer le Système
        SONAR_SERVER_NAME = 'SonarQubeServer'
    }

    stages {
        stage('1. Checkout SCM') {
            steps {
                echo "Clonage du code depuis le dépôt Git..."
                checkout scm
            }
        }

        stage('2. Maven Build & Package') {
            steps {
                echo "Exécution de 'mvn clean package' pour compiler le projet Angular..."
                sh 'mvn clean package'
            }
        }
        
        stage('3. SonarQube Analysis') {
            steps {
                echo "Lancement de l'analyse statique du code..."
                // Utilise SONAR_SERVER_NAME pour établir la connexion et injecter l'URL
                withSonarQubeEnv(SONAR_SERVER_NAME) {
                    // Récupère le jeton secret de Jenkins
                    withCredentials([string(credentialsId: env.SONAR_TOKEN_CREDENTIAL_ID, variable: 'SONAR_AUTH_TOKEN')]) {
                        sh """
                            # Utilisation du jeton injecté et du paramètre moderne -Dsonar.token
                            mvn sonar:sonar \\
                                -Dsonar.token=\$SONAR_AUTH_TOKEN \\
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                                -Dsonar.sources=src \\
                                -Dsonar.exclusions=**/node_modules/**,**/*.spec.ts,**/dist/**,**/e2e/** \\
                                -Dsonar.tests=src \\
                                -Dsonar.test.inclusions=**/*.spec.ts \\
                                -Dsonar.typescript.tsconfigPath=tsconfig.json \\
                                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                        """
                    }
                }
            }
        }

        stage('4. Quality Gate Check') {
            steps {
                echo "Attente que l'analyse SonarQube soit traitée et que la Quality Gate soit validée..."
                timeout(time: 1, unit: 'HOURS') {
                    // CORRECTION FINALE : Seul le paramètre abortPipeline est conservé.
                    // Le serveur est implicite grâce à withSonarQubeEnv au-dessus.
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('5. Archivage Artifact') {
            steps {
                echo "Archivage de l'artefact JAR final..."
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}