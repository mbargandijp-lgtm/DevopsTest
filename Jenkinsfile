pipeline {
    agent any
    
    // La section tools est retirée car l'outil 'M3' n'était pas configuré.
    // L'agent utilise donc l'installation Maven disponible dans son PATH.

    environment {
        // Variables SonarQube
        SONAR_PROJECT_KEY = 'mon-projet-devops-ci-cd'
        SONAR_TOKEN_CREDENTIAL_ID = 'SonarQube API Token for Jenkins CI' 
        SONAR_SERVER_NAME = 'SonarQubeServer'

        // NOUVELLE VARIABLE DOCKER
        // Nom de l'image Docker (Ex: mon_registre/mon_application)
        DOCKER_IMAGE_NAME = 'mini-jenkins-angular' 
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
        
        // NOUVELLE ÉTAPE 6: Création de l'image Docker
        stage('6. Build Docker Image') {
            steps {
                echo "Construction de l'image Docker pour l'application..."
                // Utilise l'ID du build Jenkins (BUILD_NUMBER) comme tag de l'image
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        // NOUVELLE ÉTAPE 7: Push de l'image Docker (Déploiement vers un registre)
        stage('7. Push Docker Image') {
            steps {
                echo "Tagging et Push de l'image vers le registre (nécessite l'accès à Docker Hub/Registry)"
                
                // Tag 'latest'
                sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                
                // Si vous aviez des identifiants (registry.hub.docker.com par exemple)
                // Vous utiliseriez 'withCredentials' ici pour le 'docker push' sécurisé.
                // sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                // sh "docker push ${DOCKER_IMAGE_NAME}:latest"

                echo "Image créée et taguée : ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} et ${DOCKER_IMAGE_NAME}:latest"
                echo "NOTE: L'étape de PUSH réelle est commentée. Décommenter pour un registre réel."
            }
        }
    }
}