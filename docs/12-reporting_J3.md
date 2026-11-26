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


