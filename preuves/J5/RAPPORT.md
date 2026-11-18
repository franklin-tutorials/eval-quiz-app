# J5 — PostgreSQL cloud (Neon)

## Choix

- **Base cloud :** Neon (PostgreSQL managé, offre gratuite), région Europe (Frankfurt), PostgreSQL 18.
- **Base locale conservée :** PostgreSQL 16 dans Docker Compose, comme exigé.
- Seul le service PostgreSQL a été activé dans Neon (pas d'authentification, de stockage ni de fonctions) : l'application n'en a pas besoin.

## Initialisation du schéma

Neon n'exécute pas `/docker-entrypoint-initdb.d` (ce mécanisme est propre à l'image Docker PostgreSQL). Le schéma a donc été initialisé manuellement, une seule fois :

```bash
docker run --rm -i postgres:18-alpine psql "$NEON_URL" < database/init.sql
```

`init.sql` n'utilisant pas `IF NOT EXISTS`, il ne doit pas être réexécuté. La table d'exemple `playing_with_neon`, créée par Neon, a été supprimée.

Le schéma est compatible avec PostgreSQL 16 (local) et 18 (Neon) : il n'utilise que du SQL standard.

## Chiffrement (TLS)

- Le code du backend ne configure pas d'option `ssl` pour le pool `pg`. Le chiffrement est imposé par la chaîne de connexion (`sslmode=require`), sans modifier le code.
- Vérification côté client (`\conninfo`) : SSL actif, **TLSv1.3**, chiffrement `TLS_AES_256_GCM_SHA384`.
- Une connexion avec `sslmode=disable` est **refusée** par Neon (`connection is insecure`).
- Remarque : `pg_stat_ssl` affiche `false` car la chaîne utilise le pooler Neon (PgBouncer). Cette vue décrit la connexion interne entre le pooler et PostgreSQL, pas celle du client. La vérification pertinente est donc `\conninfo`, côté client.
- Le paramètre `channel_binding=require` a été retiré de la chaîne : il provoquait une erreur d'analyse de l'URL et n'est pas nécessaire au chiffrement.

## Gestion du secret

La chaîne de connexion contient le mot de passe de la base : c'est un secret.

| Environnement | Stockage |
|---|---|
| Local | Variable `NEON_DATABASE_URL` dans `.env`, ignoré par Git |
| Azure Container Apps | Secret de la Container App backend, référencé par `DATABASE_URL=secretref:database-url` |
| Dépôt Git | Jamais. Les scripts lisent la valeur dans une variable d'environnement |

Le mot de passe Neon a été réinitialisé après une exposition accidentelle pendant les tests, et les secrets locaux (`JWT_SECRET`, `ADMIN_PASSWORD`) ont été régénérés avec `openssl rand`.

## Test local sur Neon

Un fichier de surcharge Compose redirige uniquement le backend vers Neon, sans modifier le Compose principal :

```bash
docker compose -f docker-compose.yml -f docker-compose.neon.yml up -d
```

Résultats :

- inscription et quiz réalisés : le résultat est enregistré dans Neon ;
- contre-preuve : l'utilisateur de test est absent de la base locale ;
- persistance : le résultat est toujours présent après `down` puis `up`.

## Déploiement Azure

Le backend Azure Container Apps reçoit la chaîne de connexion sous forme de secret :

```bash
az containerapp secret set --name <app-backend> --resource-group <groupe> \
  --secrets database-url="$NEON_URL"
az containerapp update --name <app-backend> --resource-group <groupe> \
  --set-env-vars DATABASE_URL=secretref:database-url
```

## Preuves

| Fichier | Contenu |
|---|---|
| `neon.txt` | Tables, chiffrement TLS, refus de la connexion non chiffrée, résultats enregistrés, contre-preuve locale |
| `neon-sql-editor.png` | Résultat visible dans la console Neon |