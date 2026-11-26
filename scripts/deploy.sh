#!/usr/bin/env bash

set -euo pipefail

# Création du groupe de ressource

LOCATION="switzerlandnorth"
RG="rg-quiz-app"
ACR_NAME="acrquizappmr26"

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

ACR_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
TAG=$(git rev-parse --short HEAD)

# Construction des images backend et frontend, nommées avec l'adresse de l'ACR

docker build -t "$ACR_SERVER/quiz-backend:$TAG" ./backend
docker build -t "$ACR_SERVER/quiz-frontend:$TAG" .

# Envoi des images dans l'ACR

docker push "$ACR_SERVER/quiz-backend:$TAG"
docker push "$ACR_SERVER/quiz-frontend:$TAG"

# Vérification : liste des images et de leurs tags présents dans l'ACR

az acr repository show-tags --name "$ACR_NAME" --repository quiz-backend -o table
az acr repository show-tags --name "$ACR_NAME" --repository quiz-frontend -o table