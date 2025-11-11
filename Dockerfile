# 1. Image de base pour l'étape de construction (utilisée pour build Angular si ce n'était pas fait dans Jenkins)
# Puisque le build Angular est fait dans Jenkins, on passe directement à l'étape finale.

# 2. Utilisation d'une image Nginx pour servir l'application statique
FROM nginx:alpine

# Copie le contenu du build Angular généré par Jenkins (dans le stage précédent)
# L'application est servie par défaut à cet emplacement par Nginx
COPY /dist/mini-jenkins-angular /usr/share/nginx/html

# Expose le port par défaut de Nginx
EXPOSE 80

# Commande par défaut de Nginx (qui démarre le serveur)
CMD ["nginx", "-g", "daemon off;"]