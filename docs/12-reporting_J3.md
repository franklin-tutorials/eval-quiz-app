# J3 Azure CLI

3.1 Vérifications

Installation de Azure CLI : `winget install --exact --id Microsoft.AzureCLI`

Vérification des droits de l'abonnement Azure : `az login`

AzureCloud         75234489-685f-4bd1-8f8b-adc8102b6655  True         Azure for Students  Enabled  emineo-education.com   Emineo Education     75234489-685f-4bd1-8f8b-adc8102b6655

Enregistrement des providers

`az provider register -n Microsoft.ContainerRegistry`
`az provider register -n Microsoft.App`
`az provider register -n Microsoft.OperationalInsights`

Choix de la région

Nous avons choisi "switzerlandnorth" pour des raisons de compatibilité et de faisabilité.

3.2 Création du script

Toutes les commandes seront commentées dans le fichier "scripts/deploy.sh"

Vérification 

az acr login --name "$ACR_NAME"

"Login Succeeded"

`ACR_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)`
`TAG=$(git rev-parse --short HEAD)`
`echo "$ACR_SERVER  $TAG"`

Construction des deux images

`docker build -t "$ACR_SERVER/quiz-backend:$TAG" ./backend`
`docker build -t "$ACR_SERVER/quiz-frontend:$TAG" .`

Envoie des images dans l'ACR

`docker push "$ACR_SERVER/quiz-backend:$TAG"`
`docker push "$ACR_SERVER/quiz-frontend:$TAG"`

Vérification finale : 

`az acr repository list --name "$ACR_NAME" -o table`
`az acr repository show-tags --name "$ACR_NAME" --repository` `quiz-backend -o table`
`az acr repository show-tags --name "$ACR_NAME" --repository` `quiz-frontend -o table`

Retour : 

"$ az acr repository list --name "$ACR_NAME" -o table
az acr repository show-tags --name "$ACR_NAME" --repository quiz-backend -o table
az acr repository show-tags --name "$ACR_NAME" --repository quiz-frontend -o table
Result
-------------
quiz-backend
quiz-frontend
Result
--------
9f112e5
Result
--------
9f112e5"

Les deux images sont bien présentes.