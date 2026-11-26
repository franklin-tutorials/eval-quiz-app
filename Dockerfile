# Première étape de fabrication

# On choisit une machine Linux Alpine avec Node 22 déjà installée, AS build permet de lui donner un nom (build)
# On créer un dossier /app, tout va s'inscrire là dedans
# On lance l'installation des bibliothèques (ci) avec RUN npm ci (Vite)

FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Deuxième étape

# Deuxième étape : nginx sans root
# Branche mainline 1.31 : la branche stable (1.30.6) a 4 CVE CRITICAL non corrigées dans l image officielle
FROM nginxinc/nginx-unprivileged:1.31-alpine
USER root
RUN apk upgrade --no-cache
USER nginx
# Template nginx : ${BACKEND_HOST} est remplacé au démarrage (envsubst de l image nginx)
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
ENV BACKEND_HOST=backend:3007
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/ || exit 1

# la conf de nginx qui fait en sorte que l'utilisateur de base soit l'utilisateur nginx et non root est copier dans la default conf.

