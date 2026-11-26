# Quiz App - Projet d'évaluation Conteneurisation

## Mission

Vous intégrez une équipe DevOps chargée de **conteneuriser, sécuriser et déployer** l'application **Quiz App** sur Microsoft Azure, puis d'automatiser ses livraisons.

Le **code applicatif est fourni**. Votre mission concerne la conteneurisation, l'exploitation, la sécurité et le déploiement ; **ne modifiez pas la logique métier**. Une modification ciblée d'une question de quiz présente dans le code servira à démontrer le processus de livraison.

L'application comporte un frontend, un backend et une base PostgreSQL. Elle peut utiliser un service d'envoi d'emails ; les fonctionnalités qui en dépendent doivent être configurées uniquement si les accès nécessaires sont fournis.

## Résultat attendu

1. Faire fonctionner Quiz App localement avec Docker, Docker Compose et PostgreSQL persistant.
2. Construire des images sécurisées, analyser les vulnérabilités et documenter les corrections.
3. Déployer les images via Azure Container Registry (ACR) sur Azure Container Apps avec Azure CLI.
4. Connecter le backend à un PostgreSQL externe (Neon recommandé, ou solution compatible).
5. Mettre en place une CI/CD avec **GitHub Actions (recommandé)** ou **GitLab CI/CD (autorisé)** : contrôles sur Pull/Merge Request, scan Trivy bloquant, puis publication et déploiement après fusion dans `main`.
6. Présenter le travail et les preuves de chaque jalon lors d'une soutenance.

Les jalons sont validés progressivement. Une difficulté sur PostgreSQL cloud n'annule pas les jalons déjà acquis et n'interdit pas de démontrer la partie CI/CD technique.

## Équipe et répartition du travail

| Jalon | Samy | Sofiane |
| --- | --- | --- |
| J0 · Prérequis Azure | | Vérifier l’abonnement, les droits et les quotas |
| J1 · Conteneurisation locale | Préparer le schéma, les Dockerfiles et la configuration Nginx | Préparer Docker Compose, PostgreSQL et `.env.example`, puis vérifier la persistance |
| J2 · Sécurité des images | Scanner et corriger l’image frontend avec Trivy | Scanner et corriger l’image backend avec Trivy |
| J3 à J5 · Déploiement Azure | Vérifier le parcours du quiz et l’enregistrement des résultats | Configurer ACR, Azure Container Apps et PostgreSQL cloud |
| J6 · CI/CD | Configurer les builds et le scan Trivy bloquant sur les pull requests | Automatiser la publication dans ACR et le déploiement après fusion sur `main` |

On commence par le J1. Ensemble, on termine un quiz en local et on vérifie que son résultat est toujours présent après recréation des conteneurs. Chacun relit les pull requests de l’autre.

## Travail à partir du dépôt officiel

Le formateur publie le code de départ et les consignes sur la branche `main` de son dépôt **de référence**. **Chaque groupe crée un fork de ce dépôt sur GitHub**, puis travaille exclusivement dans son fork. Les branches `feature/*` et les Pull Requests doivent cibler **`main` du fork du groupe**, jamais `main` du formateur.

- Sur GitHub : faites un fork **par groupe**, activez GitHub Actions si nécessaire et configurez vos propres secrets et autorisations Azure. Les secrets du dépôt d’origine ne sont pas transmis au fork.
- Sur GitLab (alternative admise) : créez un projet de groupe à partir du code de départ et utilisez des **Merge Requests dirigées vers `main` de votre projet**, pas vers le dépôt officiel.
- Aucun accès en écriture au dépôt du formateur n’est nécessaire. Transmettez au formateur l’URL de votre dépôt de groupe.

## Commencer

Lisez les documents dans cet ordre :

- [Présentation du projet](docs/01-presentation-projet.md)
- [Consignes techniques](docs/02-consignes-techniques.md)
- [Jalons et validations](docs/03-jalons-validation.md)
- [Exigences CI/CD](docs/04-pipeline-cicd.md)
- [Fonctionnalités avancées](docs/05-bonus-azure.md)
- [Soutenance et livrables](docs/06-soutenance-livrables.md)
- [Ressources officielles](docs/07-ressources.md)
- [Documentation technique de Quiz App : ports, API et configuration](docs/08-documentation-technique.md)
- [Utilisation responsable de l’IA](docs/09-utilisation-ia.md)

**Important :** les comptes Azure for Students peuvent être limités par les crédits, quotas, régions et autorisations. Vérifiez les possibilités de votre abonnement avant de créer des ressources payantes. Supprimez les ressources inutilisées après sauvegarde des preuves et accord du formateur.

## Règles générales

- Travail en groupe ; déposez le lien de votre dépôt et les preuves demandées au formateur.
- Versionnez les fichiers de configuration, les scripts et les workflows **que vous produisez**.
- Ne commitez jamais de mots de passe, URL PostgreSQL contenant des identifiants, clés API, secrets GitHub/GitLab ou fichiers `.env` réels.
- Une démonstration validée reste acquise même si les ressources cloud sont supprimées ensuite.
