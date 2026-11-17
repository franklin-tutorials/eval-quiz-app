Backend:

Générer un fichier package-lock.json. parce que les dépendances peuvent changer et pour s'assurer qu'on utilise les version dans package json.

On a choisi une image lightweight de node pour construire notre image.

Rajouter .dockerignore pour ignorer les node modules etc.

Database:

On a la config du nginx qui fonctionne en tant que reverse proxy.