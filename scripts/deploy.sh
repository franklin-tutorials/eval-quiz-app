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