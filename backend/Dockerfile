
FROM node:22-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./
RUN npm install
# Installer uniquement les dépendances de production
RUN npm ci --omit=dev \
    && npm cache clean --force

# Copier le code applicatif
COPY --chown=node:node server.js ./

# Exécution avec un utilisateur non privilégié
USER node

ENV NODE_ENV=production
ENV PORT=3007

EXPOSE 3007

CMD ["npm", "start"]
