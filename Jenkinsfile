// Pipeline d'Intégration Continue (CI) utilisant Maven pour gérer la compilation Angular et l'analyse SonarQube.
// Le nom 'maven_tool' doit être configuré dans Gérer Jenkins > Outils Globaux.
// Le serveur SonarQube 'SonarQubeServer' et l'identifiant 'sonar-token' doivent être configurés dans Jenkins.

pipeline {
    agent any

    // Configuration de l'outil Maven
    tools {
        // Installation Maven utilisée pour le build et l'analyse SonarQube.
        maven 'maven_tool'
    }

    stages {

        stage('Verification Initiale & Setup') {
            steps {
                echo "Démarrage du pipeline. Le code a été cloné avec succès et l'environnement Maven est prêt."
            }
        }

        stage('Maven Build (Angular + Package)') {
            steps {
                echo 'Exécution de Maven: installation des dépendances et compilation Angular...'
                // La commande 'mvn clean package' va exécuter les étapes définies dans le pom.xml
                sh 'mvn clean package'
            }
        }
        
        // --- NOUVELLE ÉTAPE 1 : ANALYSE SONARQUBE ---
        stage('SonarQube Analysis') {
            steps {
                echo "Lancement de l'analyse SonarQube via Maven avec propriétés Angular/TS..."
                
                // Le bloc withSonarQubeEnv expose automatiquement le token 'sonar-token'
                // dans la variable d'environnement 'SONAR_AUTH_TOKEN' si le Secret Text est correctement lié
                // dans la configuration du serveur Jenkins.
                withSonarQubeEnv('SonarQubeServer') {
                    // Utilisation de ${SONAR_AUTH_TOKEN} (variable injectée par withSonarQubeEnv) pour le login
                    // Ajout des propriétés spécifiques à l'analyse TypeScript/Angular.
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.login=${SONAR_AUTH_TOKEN} \
                        -Dsonar.projectKey=mon-projet-devops-ci-cd \
                        -Dsonar.sources=src \
                        -Dsonar.exclusions=**/node_modules/**,**/*.spec.ts,**/dist/**,**/e2e/** \
                        -Dsonar.tests=src \
                        -Dsonar.test.inclusions=**/*.spec.ts \
                        -Dsonar.typescript.tsconfigPath=tsconfig.json \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
                }
            }
        }

        // --- NOUVELLE ÉTAPE 2 : VÉRIFICATION DE LA QUALITY GATE ---
        stage('Quality Gate Check') {
            steps {
                echo "Attente et vérification du statut de la Quality Gate..."
                // Attend que SonarQube ait terminé l'analyse (max 5 minutes) et échoue si la Quality Gate n'est pas passée.
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }


        stage('Archivage Artifact') {
            steps {
                echo 'Archivage du JAR/WAR créé par Maven...'
                // Archive le fichier de package créé par Maven (ex: .jar ou .war)
                archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
            }
        }

        // --- ÉTAPES DÉSACTIVÉES POUR L'INSTANT (Docker) ---

        /*
        stage('Docker Construction') {
             steps {
                echo 'Construction de l image Docker...'
             }
        }
        */
    }
}