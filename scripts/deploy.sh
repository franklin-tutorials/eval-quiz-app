#!/usr/bin/env bash

set -euo pipefail

# Création du groupe de ressource

LOCATION="switzerlandnorth"
RG="rg-quiz-app"
ACR_NAME="acrquizappmr26"
ACA_ENV="env-quiz-app"

az group create --name "$RG" --location "$LOCATION" -o table

# Création de l'ACR (seulement s'il n'existe pas)
# ACR est un entrepôt privé pour les images Docker que je vais déployer sur Azure

if ! az acr show --name "$ACR_NAME" --resource-group "$RG" &>/dev/null; then
  az acr create --resource-group "$RG" --name "$ACR_NAME" --sku Basic -o table
else
  echo "ACR $ACR_NAME déjà existant"
fi

# Connexion de Docker à l'ACR avec un jeton Azure (pas de mot de passe admin)

az acr login --name "$ACR_NAME"

# Récupération de l'adresse du registre et du tag de l'image
# Le tag est le SHA court du commit git : chaque image est liée à une version précise du code
# Suffixe "-dirty" si des modifications ne sont pas commitées : l'image ne correspond alors à aucun commit exact

ACR_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
TAG=$(git rev-parse --short HEAD)$(git diff --quiet HEAD -- . || echo "-dirty")

# Construction des images backend et frontend, nommées avec l'adresse de l'ACR

docker build -t "$ACR_SERVER/quiz-backend:$TAG" ./backend
docker build -t "$ACR_SERVER/quiz-frontend:$TAG" .

# Envoi des images dans l'ACR

docker push "$ACR_SERVER/quiz-backend:$TAG"
docker push "$ACR_SERVER/quiz-frontend:$TAG"

# Vérification : liste des images et de leurs tags présents dans l'ACR

az acr repository show-tags --name "$ACR_NAME" --repository quiz-backend -o table
az acr repository show-tags --name "$ACR_NAME" --repository quiz-frontend -o table

# ===== J4 : Azure Container Apps =====

# Environnement Container Apps : réseau et logs partagés par le frontend et le backend
# Mode WorkloadProfiles obligatoire : le mode Express (choisi par défaut) refuse l'identité managée pour l'ACR

if ! az containerapp env show --name "$ACA_ENV" --resource-group "$RG" &>/dev/null; then
  az containerapp env create --name "$ACA_ENV" --resource-group "$RG" --location "$LOCATION" --environment-mode WorkloadProfiles -o table
else
  echo "Environnement $ACA_ENV déjà existant"
fi

# Chargement des secrets depuis .env.azure (fichier local, ignoré par git)
# En CI/CD, ces variables viendront des secrets GitHub : le fichier est donc optionnel

if [ -f .env.azure ]; then
  set -a; source .env.azure; set +a
fi

# Arrêt immédiat si un secret obligatoire est absent

: "${JWT_SECRET:?JWT_SECRET manquant}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD manquant}"
: "${RESEND_API_KEY:?RESEND_API_KEY manquant}"
: "${ADMIN_USERNAME:?ADMIN_USERNAME manquant}"
: "${FROM_EMAIL:?FROM_EMAIL manquant}"

# Backend : ingress interne (non accessible depuis Internet), image tirée de l'ACR via identité managée
# Création si l'app n'existe pas, sinon mise à jour de l'image et des secrets (nouvelle révision)

if ! az containerapp show --name backend --resource-group "$RG" &>/dev/null; then
  az containerapp create \
    --name backend \
    --resource-group "$RG" \
    --environment "$ACA_ENV" \
    --image "$ACR_SERVER/quiz-backend:$TAG" \
    --registry-server "$ACR_SERVER" \
    --registry-identity system \
    --ingress internal \
    --target-port 3007 \
    --secrets "jwt-secret=$JWT_SECRET" "admin-password=$ADMIN_PASSWORD" "resend-api-key=$RESEND_API_KEY" \
    --env-vars "ADMIN_USERNAME=$ADMIN_USERNAME" "FROM_EMAIL=$FROM_EMAIL" \
               "JWT_SECRET=secretref:jwt-secret" "ADMIN_PASSWORD=secretref:admin-password" "RESEND_API_KEY=secretref:resend-api-key" \
    -o table

  # HTTP autorisé sur l'ingress interne : nginx appelle http://backend (le trafic reste dans l'environnement)
  
  az containerapp ingress update --name backend --resource-group "$RG" --allow-insecure -o table
else
  az containerapp secret set --name backend --resource-group "$RG" \
    --secrets "jwt-secret=$JWT_SECRET" "admin-password=$ADMIN_PASSWORD" "resend-api-key=$RESEND_API_KEY" -o none
  az containerapp update --name backend --resource-group "$RG" \
    --image "$ACR_SERVER/quiz-backend:$TAG" \
    --set-env-vars "ADMIN_USERNAME=$ADMIN_USERNAME" "FROM_EMAIL=$FROM_EMAIL" -o table
fi

# Frontend : ingress externe (URL publique en HTTPS), nginx écoute sur 8080 (image non-root)
# BACKEND_HOST=backend:80 : nginx joint le backend par son nom d'app, sur le port 80 de l'ingress interne
# (en local, la valeur par défaut du Dockerfile reste backend:3007)

if ! az containerapp show --name frontend --resource-group "$RG" &>/dev/null; then
  az containerapp create \
    --name frontend \
    --resource-group "$RG" \
    --environment "$ACA_ENV" \
    --image "$ACR_SERVER/quiz-frontend:$TAG" \
    --registry-server "$ACR_SERVER" \
    --registry-identity system \
    --ingress external \
    --target-port 8080 \
    --env-vars "BACKEND_HOST=backend:80" \
    -o table
else
  az containerapp update --name frontend --resource-group "$RG" \
    --image "$ACR_SERVER/quiz-frontend:$TAG" \
    --set-env-vars "BACKEND_HOST=backend:80" -o table
fi

# Vérification : état des révisions, URL publique et test de /health à travers le frontend

for app in backend frontend; do
  az containerapp revision list --name "$app" --resource-group "$RG" \
    --query "[?properties.active].{app:'$app', revision:name, sante:properties.healthState, replicas:properties.replicas}" -o table
done

FRONTEND_URL="https://$(az containerapp show --name frontend --resource-group "$RG" --query properties.configuration.ingress.fqdn -o tsv)"
echo "Frontend : $FRONTEND_URL"
curl -s -w "  (HTTP %{http_code})\n" "$FRONTEND_URL/health"