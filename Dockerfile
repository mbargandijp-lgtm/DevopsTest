# Dockerfile pour l'application Angular packagée en JAR
# --------------------------------------------------

# ÉTAPE 1: Image de base pour exécuter le JAR (ici OpenJDK)
FROM openjdk:17-jdk-slim

# Configuration de l'environnement
ENV APP_NAME=mini-jenkins-angular.jar

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier l'artefact JAR final généré par Maven (présent dans target/ après l'étape 2)
# Nous supposons que le JAR s'appelle 'mini-jenkins-angular.jar'
COPY target/${APP_NAME} /app/

# Port d'écoute par défaut de l'application (à ajuster si nécessaire)
EXPOSE 8080

# Commande d'exécution de l'application
CMD ["java", "-jar", "${APP_NAME}"]