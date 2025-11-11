// Pipeline d'Intégration Continue (CI) utilisant Maven pour gérer la compilation Angular.
// Le nom 'maven_tool' doit être configuré dans Gérer Jenkins > Outils Globaux.

pipeline {
    agent any

    // Configuration de l'outil Maven
    tools {
        // Cette ligne ne sera valide que si le plugin 'Maven Integration' est installé
        // et que l'installation 'maven_tool' est définie dans Jenkins.
        maven 'maven_tool'
    }

    stages {

        stage('Verification Initiale & Setup') {
            steps {
                echo "Démarrage du pipeline. Le code a été cloné avec succès."
            }
        }

        stage('Maven Build (Angular + Package)') {
            steps {
                echo 'Exécution de Maven: installation des dépendances et compilation Angular...'
                // La commande 'mvn clean package' va exécuter les étapes définies dans le pom.xml
                sh 'mvn clean package'
            }
        }

        stage('Archivage Artifact') {
            steps {
                echo 'Archivage du JAR/WAR créé par Maven...'
                // Archive le fichier de package créé par Maven (ex: .jar ou .war)
                archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
            }
        }

        // --- ÉTAPES DÉSACTIVÉES POUR L'INSTANT (Docker, SonarQube, etc.) ---

        /*
        stage('Docker Construction') {
             steps {
                echo 'Construction de l image Docker...'
             }
        }
        */
    }
}
