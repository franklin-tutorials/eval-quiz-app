# La base du Dockerfile

# On par d'un Linux Alpine avec Node 22, on indique qu'on est en production, et on se place dans le dossier `/app`


FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copie des bibliothèques avec LA VERSION EXACTE du lock, on copie le code en dernier


FROM node:22-alpine
ENV NODE_ENV=production

RUN apk upgrade --no-cache \
 && rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
           /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack \
           /opt/yarn-* /usr/local/bin/yarn /usr/local/bin/yarnpkg


# Apk upgrade permet de mettre à jour l'image.
# permet de recuperer uniquement ce qu'on copiera de l'image de l'étape 1

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json server.js ./

# permet de juste copier ce qui sert à l'exécution donc la package.json nécessaire pour "type": "module") et server.js

USER node
EXPOSE 3007
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3007/health || exit 1
CMD ["node", "server.js"]

# Démarrage, on fait tourner l'application en utilisateur, sur le bon port d'écoute, CMD pour lancer des commandes au démarrage du conteneur et HEALTHCHECK

