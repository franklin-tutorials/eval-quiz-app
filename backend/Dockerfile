# La base du Dockerfile

# On par d'un Linux Alpine avec Node 22, on indique qu'on est en production, et on se place dans le dossier `/app`


FROM node:22-alpine 
ENV NODE_ENV=production
WORKDIR /app

# Copie des bibliothèques avec LA VERSION EXACTE du lock, on copie le code en dernier

COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY server.js ./

# Démarrage, on fait tourner l'application en utilisateur, sur le bon port d'écoute, CMD pour lancer des commandes au démarrage du conteneur

USER node
EXPOSE 3007
CMD ["node", "server.js"]

