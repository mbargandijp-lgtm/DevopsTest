pipeline {
    agent any
    
    // Déclaration des outils
    tools {
        // Le nom doit correspondre à votre configuration Maven dans Gérer Jenkins -> Global Tool Configuration
        maven 'M3' 
    }

    // Déclaration des variables d'environnement
    environment {
        // Clé du projet SonarQube (DOIT correspondre à l'identifiant que vous utilisez)
        SONAR_PROJECT_KEY = 'mon-projet-devops-ci-cd'
        
        // Nom de l'identifiant Jenkins de type "Secret text" qui contient le jeton SonarQube
        // Doit correspondre à l'ID créé : 'SonarQube API Token for Jenkins CI'
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
                echo "Exécution de 'mvn clean package' pour compiler le projet Angular et créer l'artefact JAR..."
                // Cette commande exécute le cycle de vie Maven, incluant la compilation Angular via le plugin frontend-maven-plugin.
                sh 'mvn clean package'
            }
        }
        
        stage('3. SonarQube Analysis') {
            steps {
                echo "Lancement de l'analyse statique du code..."
                // 1. Injecte l'URL du serveur SonarQube
                withSonarQubeEnv(SONAR_SERVER_NAME) {
                    // 2. Récupère le jeton secret de Jenkins et l'injecte dans la variable SONAR_AUTH_TOKEN
                    withCredentials([string(credentialsId: env.SONAR_TOKEN_CREDENTIAL_ID, variable: 'SONAR_AUTH_TOKEN')]) {
                        sh """
                            # Commande d'analyse utilisant le jeton injecté (plus sécurisé et moderne que -Dsonar.login)
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
                // Met en pause le pipeline jusqu'à ce que SonarQube réponde
                timeout(time: 1, unit: 'HOURS') {
                    // Si la Quality Gate échoue, le pipeline est abandonné (abortPipeline: true)
                    waitForQualityGate abortPipeline: true, toolName: env.SONAR_SERVER_NAME
                }
            }
        }
        
        stage('5. Archivage Artifact') {
            steps {
                echo "Archivage de l'artefact (mini-jenkins-angular.jar) si la Quality Gate est verte..."
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}