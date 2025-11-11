pipeline {
    agent any

    stages {
        stage('Verification Initiale') {
            steps {
                echo "Hello World! Le pipeline commence bien."
            }
        }

        stage('GIT Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/mbargandijp-lgtm/test DevOps.git',
                    credentialsId: 'jenkins-git'
            }
        }

        stage('Angular Build') {
            steps {
                sh 'npm install'
                sh 'npm run build --prod'
            }
        }

        stage('Archivage Artifact') {
            steps {
                archiveArtifacts artifacts: 'dist/mini-jenkins-angular/**', onlyIfSuccessful: true
            }
        }

       stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube Local') {
                    // Ceci récupère le secret 'sonarqube-token' et le met dans la variable SONAR_TOKEN
                    withCredentials([string(credentialsId: 'sonartoken', variable: 'SONAR_TOKEN')]) {
                        // On passe le jeton au scanner Maven (résout l'erreur Not authorized)
                        sh "mvn sonar:sonar -Dsonar.token=${SONAR_TOKEN}"
                    }
                }
            }
        }

        // ... stage SonarQube Analysis ...

        stage('Docker Build') {
            steps {
                // Construit l'image Docker en utilisant le Dockerfile à la racine
                // ATTENTION: VOTRE_ID_DOCKER par votre nom d'utilisateur Docker Hub
                sh 'docker build -t stagiaire007/mini-jenkins-angular:1.0 . --no-cache'
            }
        }
/*

          // NOUVEAU STAGE A : Scan de Secrets (Gitleaks)


        stage('Secrets Scan (Gitleaks)') {
            steps {
                echo "Recherche de secrets exposés dans le dépôt Git..."
                // Scanner le répertoire de travail ($PWD)
                // Le pipeline échoue (exit code 1) si Gitleaks trouve des secrets.
                sh 'gitleaks detect --source=$PWD --exit-code 1 --config=.gitleaks.toml --redact'
            }
        }


//

        //NOUVEAU STAGE B : Scan d'Image (Trivy - SCA/Docker Scan)

        stage('Security Scan (Trivy)') {
            steps {
                echo "Démarrage de l'analyse de vulnérabilités pour l'image stagiaire007/mini-jenkins-angular:1.0"

                // Définir des règles de blocage [cite: 20]
                // Le pipeline échoue (exit code 1) si des vulnérabilités CRITICAL ou HIGH sont trouvées[cite: 20].
                sh 'trivy image --exit-code 1 --severity CRITICAL,HIGH stagiaire007/mini-jenkins-angular:1.0'
            }
        }


        // ... stage Docker Push ...


        stage('Docker Push') {
            steps {
                // 🔑 Étape d'authentification Docker Hub
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials', // ⬅️ L'ID de l'identifiant créé ci-dessus
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    // 1. Se connecter à Docker Hub en utilisant le PAT comme mot de passe
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"

                    // 2. Pousser l'image
                    sh 'docker push kerenmputu2209/mini-jenkins-angular:1.0'
                }
            }
        }

        stage('Deployment') {
            steps {
                sh '''
                    echo "Arrêt de l'ancien conteneur..."
                    docker stop mini-jenkins-angular || true

                    echo "Suppression de l'ancien conteneur..."
                    docker rm mini-jenkins-angular || true

                    # COMMANDE CORRIGÉE : Tout sur une seule ligne
                    echo "Démarrage du nouveau conteneur sur le port 8081..."
                    docker run -d -p 8081:80 --name mini-jenkins-angular kerenmputu2209/mini-jenkins-angular:1.0

                    echo "Déploiement terminé. Application accessible sur le port 8081 de la machine Jenkins."
                '''
            }
        }

      stage('Dynamic Scan (DAST)') {
            steps {
                echo "Démarrage du scan dynamique sur l'application déployée sur http://localhost:8081"

                // Cette commande est un marqueur de position.
                // Pour la valider, vous devez installer et configurer un outil DAST.
                sh 'echo "Simulating DAST scan on running application..." && sleep 5'
                // Si vous avez ZAP CLI installé, vous pouvez utiliser :
                // sh 'owasp-zap-cli scan --target http://localhost:8081'
            }
        }
  */

    }
}
