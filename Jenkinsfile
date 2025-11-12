pipeline {
    agent any
    
    // Déclaration des outils
    tools {
        maven 'M3' // Assurez-vous que c'est le nom de votre configuration Maven dans Gérer Jenkins
    }

    // Déclaration des variables d'environnement pour le projet SonarQube
    environment {
        // La clé du projet SonarQube
        SONAR_PROJECT_KEY = 'mon-projet-devops-ci-cd'
        // Le nom du credential Jenkins qui contient le Jeton SonarQube (le secret sera masqué)
        SONAR_TOKEN_CREDENTIAL_ID = 'jeton sonar' // C'est le nom du credential que vous utilisez (voir votre image)
        // L'URL du serveur SonarQube (Utilise l'adresse IP si configurée dans "Gérer Jenkins -> Configurer le Système")
        SONAR_SERVER_NAME = 'SonarQubeServer'
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Verification Initiale & Setup') {
            steps {
                echo "Démarrage du pipeline. Le code a été cloné avec succès et l'environnement Maven est prêt."
            }
        }
        
        stage('Maven Build (Angular + Package)') {
            steps {
                echo "Exécution de Maven: installation des dépendances et compilation Angular..."
                // Nettoyage, installation des dépendances Node/NPM, et compilation Angular
                sh 'mvn clean package'
            }
        }
        
        stage('SonarQube Analysis') {
            // Utilise withSonarQubeEnv pour injecter l'URL du serveur, mais on ajoute le token explicite dans la commande
            steps {
                echo "Lancement de l'analyse SonarQube via Maven avec propriétés Angular/TS..."
                withSonarQubeEnv(SONAR_SERVER_NAME) {
                    // Récupère le secret du token depuis le credential stocké dans Jenkins
                    // et l'utilise explicitement dans la commande.
                    withCredentials([string(credentialsId: env.SONAR_TOKEN_CREDENTIAL_ID, variable: 'SONAR_LOGIN_TOKEN')]) {
                        sh """
                            mvn sonar:sonar \
                                -Dsonar.login=$SONAR_LOGIN_TOKEN \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=src \
                                -Dsonar.exclusions=**/node_modules/**,**/*.spec.ts,**/dist/**,**/e2e/** \
                                -Dsonar.tests=src \
                                -Dsonar.test.inclusions=**/*.spec.ts \
                                -Dsonar.typescript.tsconfigPath=tsconfig.json \
                                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                        """
                    }
                }
            }
        }

        // Ces étapes sont généralement exécutées après la Quality Gate Check
        stage('Quality Gate Check') {
            steps {
                // Attendre le résultat de l'analyse SonarQube (vérifie la Quality Gate)
                // Le timeout de 1 heure est généralement suffisant
                timeout(time: 1, unit: 'HOURS') {
                    // Utilise le nom du serveur SonarQube configuré
                    waitForQualityGate abortPipeline: true, toolName: env.SONAR_SERVER_NAME
                }
            }
        }
        
        stage('Archivage Artifact') {
            steps {
                echo "Archivage de l'artefact (mini-jenkins-angular.jar)..."
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}