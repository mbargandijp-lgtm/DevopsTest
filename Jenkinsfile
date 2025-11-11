//
// Pipeline DevOps complet pour une application Angular, intégrant :
// 1. Installation des dépendances (npm)
// 2. Build Angular (ng build)
// 3. Analyse de qualité (SonarQube)
// 4. Construction et Push de l'image Docker
// 5. Déploiement du conteneur
//

pipeline {
    // Exécuté sur n'importe quel agent disponible (votre VM Vagrant ou Docker Container)
    agent any

    // Définition des outils nécessaires (Node.js et, si besoin, Maven pour SonarQube)
    tools {
        // Le nom 'nodejs_tool' DOIT correspondre au nom configuré dans
        // Gérer Jenkins > Outils Globaux > Installations NodeJS
        nodejs 'nodejs_tool'
        // Si vous utilisez le scanner SonarQube basé sur Maven:
        // maven 'Maven 3.8.4'
    }

    stages {

        stage('Verification Initiale & Setup') {
            steps {
                echo "Hello World! Le pipeline commence bien."
                // Vérification du clonage réussi par la configuration du job
            }
        }

        // Nous avons supprimé le 'stage('GIT Clone')' explicite car il était redondant et échouait.

        stage('Install Dependencies') {
            steps {
                echo 'Installation des dépendances npm...'
                // npm ci (Clean Install) est plus rapide et fiable pour la CI que npm install
                sh 'npm ci'
            }
        }

        stage('Angular Build') {
            steps {
                echo 'Construction du projet Angular en mode production...'
                // La commande moderne (Angular 12+) utilise 'ng build' sans --prod
                sh 'ng build --configuration=production'
            }
        }

        stage('Archivage Artifact') {
            steps {
                echo 'Archivage des fichiers de build pour la distribution...'
                // Assurez-vous que 'mini-jenkins-angular' est le nom du dossier créé par 'ng build'
                archiveArtifacts artifacts: 'dist/mini-jenkins-angular/**', onlyIfSuccessful: true
            }
        }

       stage('SonarQube Analysis') {
            steps {
                echo 'Démarrage de l analyse SonarQube...'
                // L'environnement SonarQube doit être configuré dans Jenkins
                withSonarQubeEnv('SonarQube Local') {
                    // Les identifiants 'sonartoken' doivent exister dans Jenkins (Settings > Credentials)
                    withCredentials([string(credentialsId: 'sonartoken', variable: 'SONAR_TOKEN')]) {
                        // Utilisation du scanner SonarQube pour Node.js/Angular
                        // Assurez-vous que 'sonar-scanner' est accessible ou utilisez un outil comme Maven/NPM si configuré
                        sh "npm install -g sonar-scanner"
                        sh "sonar-scanner -Dsonar.token=${SONAR_TOKEN}"

                        // Si vous préférez Maven (dépend des outils configurés)
                        // sh "mvn sonar:sonar -Dsonar.token=${SONAR_TOKEN}"
                    }
                }
            }
        }

        stage('Docker Construction') {
            steps {
                echo 'Construction de l image Docker pour le déploiement...'
                // L'image sera taguée avec votre nom d'utilisateur Docker Hub
                // ATTENTION : Remplacer stagiaire007 par votre VRAI ID Docker Hub.
                sh 'docker build -t stagiaire007/mini-jenkins-angular:1.0 .'
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Authentification et Push de l image vers Docker Hub...'
                // L'identifiant 'docker-hub-credentials' doit exister dans Jenkins
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    // 1. Se connecter à Docker Hub
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"

                    // 2. Pousser l'image
                    sh 'docker push stagiaire007/mini-jenkins-angular:1.0'
                }
            }
        }

        stage('Deployment') {
            steps {
                sh '''
                    echo "Arrêt de l ancien conteneur..."
                    docker stop mini-jenkins-angular || true

                    echo "Suppression de l ancien conteneur..."
                    docker rm mini-jenkins-angular || true

                    echo "Démarrage du nouveau conteneur sur le port 8081..."
                    // Le conteneur doit être déployé sur le serveur où Jenkins est capable d'exécuter Docker
                    docker run -d -p 8081:80 --name mini-jenkins-angular stagiaire007/mini-jenkins-angular:1.0

                    echo "Déploiement terminé. Application accessible sur le port 8081 de la machine Jenkins."
                '''
            }
        }
    }
}
