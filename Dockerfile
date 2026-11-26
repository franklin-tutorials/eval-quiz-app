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

FROM nginx:alpine
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
