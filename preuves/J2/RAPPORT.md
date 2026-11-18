# J2 — Sécurité des images

## Objectif

Analyser les images frontend et backend avec Trivy, corriger les vulnérabilités pertinentes, réanalyser et documenter les vulnérabilités résiduelles.

## Méthode

1. Scan Trivy initial des deux images construites au J1.
2. Identification de l'origine de chaque vulnérabilité CRITICAL et HIGH (paquet, chemin, version corrigée).
3. Corrections dans les Dockerfiles.
4. Vérification du fonctionnement de l'application.
5. Scan Trivy final et analyse des vulnérabilités résiduelles.

Outil : Trivy (`aquasec/trivy:latest`), exécuté en conteneur.

## Commandes utilisées

```bash
# Scan complet de chaque image
for img in quiz-frontend:local quiz-backend:local; do
  name=$(echo "$img" | cut -d: -f1)
  docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/trivy-cache:/root/.cache/ \
    aquasec/trivy:latest image "$img" > "preuves/J2/scan-initial-$name.txt"
done
grep -H "Total:" preuves/J2/scan-initial-*.txt

# Détail des vulnérabilités CRITICAL et HIGH
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/trivy-cache:/root/.cache/ \
  aquasec/trivy:latest image --scanners vuln --severity CRITICAL,HIGH quiz-backend:local
```

Le scan final utilise les mêmes commandes, avec des fichiers `scan-final-*.txt`.

> Le socket Docker est monté dans le conteneur Trivy pour lui permettre de lire les images locales. Ce montage est acceptable pour un outil d'audit ponctuel supprimé après exécution (`--rm`), jamais pour un conteneur applicatif.

## État initial

| Image | Taille | Utilisateur | CRITICAL | HIGH | MEDIUM | LOW |
|---|---|---|---|---|---|---|
| `quiz-frontend:local` | 92,8 Mo | root | 0 | 3 | 2 | 0 |
| `quiz-backend:local` | 268 Mo | node | 0 | 10 | 15 | 1 |
| **Total** | | | **0** | **13** | **17** | **1** |

### Vulnérabilités HIGH identifiées

**Frontend :** 3 vulnérabilités dans la bibliothèque système `libxslt` (CVE-2026-125350, CVE-2026-87636, CVE-2026-9947), version 1.1.43-r3. Un correctif existe (1.1.43-r4).

**Backend :** 10 vulnérabilités, toutes situées dans `/usr/local/lib/node_modules/npm/`, c'est-à-dire dans le gestionnaire de paquets npm livré avec l'image `node` :

| Paquet | Nombre | Type |
|---|---|---|
| brace-expansion | 5 | Déni de service |
| pacote | 2 | Déni de service |
| ip-address | 1 | SSRF |
| picomatch | 1 | Déni de service (ReDoS) |
| sigstore | 1 | Vérification de certificats |

**Aucune vulnérabilité HIGH dans les dépendances de l'application** (`/app/node_modules`).

### Autres constats

- Le frontend (nginx) s'exécute en root.
- Le backend embarque npm, npx, yarn et corepack, inutiles à l'exécution (`node server.js`).
- Le backend n'a pas de `package-lock.json` : les versions des dépendances ne sont pas figées et le build n'est pas reproductible.
- Les tags d'images (`node:22-alpine`, `nginx:stable-alpine`) sont flottants.

## Corrections appliquées

| # | Correction | Image | Justification |
|---|---|---|---|
| 1 | Build multi-stage : `npm ci` dans une étape `deps`, image finale sans npm, npx, yarn ni corepack | Backend | Les 10 HIGH sont dans npm, outil inutile à l'exécution. On retire l'outil plutôt que de le corriger |
| 2 | Génération d'un `package-lock.json` et utilisation de `npm ci --omit=dev` | Backend | Versions des dépendances figées, build reproductible, dépendances de production uniquement |
| 3 | `apk upgrade --no-cache` | Frontend et backend | Application des correctifs Alpine (dont `libxslt` 1.1.43-r4) |
| 4 | Image `nginxinc/nginx-unprivileged`, `USER 101`, écoute sur le port 8080 | Frontend | nginx ne s'exécute plus en root. Un processus non-root ne pouvant pas écouter sous le port 1024, `nginx.conf` passe de `listen 80` à `listen 8080`, et Compose publie `8087:8080` |
| 5 | Tags précis : `node:22-alpine3.24`, `nginxinc/nginx-unprivileged:1-alpine3.24` | Les deux | Builds reproductibles et maîtrise des mises à jour |

Le `package-lock.json` et `nginx.conf` sont des fichiers de configuration : la logique métier de l'application n'est pas modifiée.

## État final

| Image | Taille | Utilisateur | CRITICAL | HIGH | MEDIUM | LOW |
|---|---|---|---|---|---|---|
| `quiz-frontend:local` | 100 Mo | nginx (101) | 0 | 0 | 0 | 0 |
| `quiz-backend:local` | 265 Mo | node | 0 | 0 | 2 | 0 |
| **Total** | | | **0** | **0** | **2** | **0** |

### Évolution

| Gravité | Avant | Après |
|---|---|---|
| CRITICAL | 0 | 0 |
| HIGH | 13 | **0** |
| MEDIUM | 17 | **2** |
| LOW | 1 | **0** |

### Taille des images

- **Frontend : +7 Mo.** L'`apk upgrade` ajoute une couche contenant les paquets corrigés. Les couches étant immuables, les anciennes versions restent stockées dans les couches inférieures. L'image de base `nginx-unprivileged` diffère aussi légèrement de `nginx:stable-alpine`. Ce surcoût est accepté au profit de la suppression des HIGH et du passage en non-root.
- **Backend : −3 Mo seulement.** La suppression de npm dans l'image finale le retire du système de fichiers visible (Trivy ne le détecte plus), mais les couches de l'image de base qui le contiennent restent stockées. Le gain porte sur la sécurité, pas sur la taille.

## Vérifications

```bash
docker compose ps                         # 3 services Up (healthy)
curl -i http://localhost:8087/health      # HTTP 200 {"status":"ok"}
docker run --rm quiz-frontend:local whoami                       # nginx
docker run --rm --entrypoint sh quiz-backend:local \
  -c "whoami; which npm yarn npx || echo 'aucun outil de build'" # node, aucun outil de build
```

Un quiz complet et la consultation du résultat dans `/gestion-quiz` confirment que les corrections n'ont pas cassé l'application.

## Vulnérabilités résiduelles

| Paquet | CVE | Installé | Corrigé | Gravité | Type |
|---|---|---|---|---|---|
| glob | CVE-2026-118773 | 10.5.0 | 14.0.2 | MEDIUM | Déni de service |
| minimatch | CVE-2026-118764 | 9.0.9 | 11.0.1 | MEDIUM | Déni de service |

**Origine :** dépendances indirectes, tirées par la bibliothèque d'e-mails `resend` (via `@react-email/render`, `pretty` et `js-beautify`). Elles ne figurent pas dans `backend/package.json`.

**Décision : risque accepté et documenté.**

1. La correction impose une **mise à jour de version majeure** (glob 10 → 14, minimatch 9 → 11) de dépendances que nous ne contrôlons pas. La forcer (`overrides` npm) risque de casser l'envoi d'e-mails, et la logique métier ne doit pas être modifiée.
2. Le **vecteur d'attaque n'est pas atteignable** : ces CVE nécessitent qu'un attaquant fournisse un motif de fichiers piégé. Dans Quiz App, aucune entrée utilisateur n'atteint `glob` ou `minimatch`, utilisés uniquement pour la mise en forme du HTML des e-mails.
3. La gravité est **MEDIUM** : la politique du projet (blocage sur CRITICAL) n'est pas concernée.
4. Le scan Trivy de la CI les signalera à chaque build. Une mise à jour de `resend` intégrant des versions corrigées suffira à les supprimer.

## Limites et pistes d'amélioration

- **Image distroless pour le backend** : elle ne contient ni npm ni shell, ce qui réduirait la taille et la surface d'attaque. Le healthcheck devrait alors être réécrit sans `wget`.
- **Pinning par digest** (`@sha256:...`) pour une immuabilité totale des images de base.
- **Reconstruction régulière** des images pour intégrer les nouveaux correctifs.
- **Durcissement à l'exécution** dans Compose : `read_only`, `cap_drop: ALL`, `no-new-privileges`, limites de ressources.
- Un résultat de 0 CVE connue à une date donnée ne garantit pas l'absence de faille : de nouvelles vulnérabilités sont publiées en continu, d'où le scan dans la CI.

## Fichiers de preuve

| Fichier | Contenu |
|---|---|
| `scan-initial-quiz-frontend.txt` | Scan Trivy initial du frontend |
| `scan-initial-quiz-backend.txt` | Scan Trivy initial du backend |
| `scan-final-quiz-frontend.txt` | Scan Trivy final du frontend |
| `scan-final-quiz-backend.txt` | Scan Trivy final du backend |