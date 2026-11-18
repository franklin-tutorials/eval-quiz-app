
# Stage 1 : construction de l'application
FROM node:22-alpine AS builder

WORKDIR /app

# Copier les dépendances
COPY package.json package-lock.json ./

# Installation reproductible
RUN npm ci

# Copier le code source
COPY . .

# Construire les fichiers statiques
RUN npm run build


# Stage 2 : serveur de production
FROM nginxinc/nginx-unprivileged:stable-alpine AS production

# Copier les fichiers générés par Vite
COPY --from=builder --chown=101:101 \
    /app/dist/ /usr/share/nginx/html/

# Configuration du reverse proxy
COPY --chown=101:101 \
    nginx/nginx.conf /etc/nginx/conf.d/default.conf


    
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
