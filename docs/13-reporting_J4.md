# 1 Extension Container Apps et environnement

Installation ou mise à jour de "containerapp"

`az extension add --name containerapp --upgrade`

Création de l'environnement. 
On créer également un Log Analytics workspace afin de stocker les logs

`az containerapp env create --name "$ACA_ENV" --resource-group "$RG" --location "$LOCATION" -o table`

Vérification 

`az containerapp env show --name "$ACA_ENV" --resource-group "$RG" --query "{nom:name, etat:properties.provisioningState, region:location}" -o table`

Retour : "$ az containerapp env show --name "$ACA_ENV" --resource-group "$RG" --query "{nom:name, etat:properties.provisioningState, region:location}" -o table
The behavior of this command has been altered by the following extension: containerapp
Nom           Etat       Region
------------  ---------  -----------------
env-quiz-app  Succeeded  Switzerland North"

# Déployer le backend

Création du fichier .env.azure pour y intégrer les secrets hors du dépôt

Commentaires ajoutés sur le fichier deploy.sh

Il fallait bien déployer l'environement non pas en mode Express mais en mode Standard

# Déployer le frontend

Tout est renseigné dans le fichier "deploy.sh"


# Diagnostic : environnement créé en mode Express

Erreur rencontrée à la création du backend :

`(ExpressRegistrySystemIdentityNotSupported) System-assigned managed identity for container registry authentication is not supported for container app 'backend' on express environments.`

Cause : sans option, `az containerapp env create` a créé l'environnement en mode **Express**, qui refuse l'identité managée pour s'authentifier à l'ACR.

Solution : suppression de l'environnement puis recréation en mode standard :

`az containerapp env create --name "$ACA_ENV" --resource-group "$RG" --location "$LOCATION" --environment-mode WorkloadProfiles -o table`

On garde ainsi l'accès à l'ACR par identité managée (rôle AcrPull), sans activer le compte admin du registre ni stocker de mot de passe.

# Communication frontend → backend

En local, nginx joint le backend sur `backend:3007`. Dans Container Apps, le backend se joint par son nom d'app sur le port 80 de son ingress interne : `backend:80`.

La config nginx est devenue un template (`nginx/default.conf.template`) : `${BACKEND_HOST}` est remplacé au démarrage du conteneur.
- valeur par défaut dans le Dockerfile : `backend:3007` (Docker Compose, inchangé)
- valeur sur Azure : `BACKEND_HOST=backend:80`

Le header `Host` envoyé au backend est `$proxy_host` (et non plus `$host`), car le routeur interne d'Azure choisit l'app de destination d'après ce header.

L'ingress interne du backend autorise le HTTP (`--allow-insecure`) : nginx appelle `http://backend`, le trafic reste dans le réseau de l'environnement.

# Preuves

Toutes les sorties sont dans `docs/preuves-J4/` (aucun secret : les valeurs sensibles sont des `secretref`, le nom d'admin et l'IP sont masqués).

| Ce qui est demandé | Preuve | Résultat |
|---|---|---|
| Environnement Container Apps | `01-environnement.txt` | `Succeeded`, mode `WorkloadProfiles`, Switzerland North |
| Deux apps, images tirées d'ACR | `02-configuration-apps.txt` | images `acrquizappmr26.azurecr.io/quiz-*`, authentification `system` (identité managée) |
| Ingress du frontend | `02-configuration-apps.txt` | externe, port cible 8080 |
| Configuration réseau backend | `02-configuration-apps.txt` + `05-tests-http.txt` | ingress interne, port 3007, **404 depuis Internet** |
| Secrets | `02-configuration-apps.txt` | `JWT_SECRET`, `ADMIN_PASSWORD`, `RESEND_API_KEY` en `secretRef` |
| État des révisions | `03-revisions.txt` | `backend--0000002` et `frontend--0000001` : `Healthy`, `Running`, 100 % du trafic |
| Images et tags dans l'ACR | `04-images-acr.txt` | tags = SHA du commit, avec digest |
| `GET /health` | `05-tests-http.txt` | **HTTP 200** `{"status":"ok"}` (réponse `x-powered-by: Express` à travers nginx) |
| Proxy `/api` | `05-tests-http.txt` | **HTTP 401** `{"error":"Token required"}` : la requête atteint bien Express |
| Logs des révisions | `06-logs.txt` | backend : `Server running on port 3007` ; frontend : requêtes 200/401 dans les logs nginx |

URL du frontend : https://frontend.icysea-a9d6a9a8.switzerlandnorth.azurecontainerapps.io

Remarque sur le tag `a27379f-dirty` : les images ont été construites avant le commit des modifications de J4. Le suffixe `-dirty` (ajouté automatiquement par `deploy.sh`) signale que l'image ne correspond à aucun commit exact. Le prochain déploiement après commit produit un tag propre.

# Limite connue (J5)

Le backend n'a pas encore de `DATABASE_URL` : `/health` répond 200 car il n'interroge pas PostgreSQL, mais l'inscription et l'enregistrement des résultats échoueront tant que la base cloud (J5) n'est pas branchée. Le démarrage du backend n'est pas bloqué par l'absence de base (la connexion n'est ouverte qu'à la première requête).
