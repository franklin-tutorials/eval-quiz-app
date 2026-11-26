# Jalon 2


2.0 : lancer trivy avec docker

`alias trivy='docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v trivy-cache:/root/.cache/ \
  -v "$PWD":/work -w /work \
  aquasec/trivy:latest'

trivy --version`

cette commande permet d'aller chercher trivy dans un conteneur et permet à trivy de voir les images dans mon docker local.

2.1 construire les images avant correction :


`docker build -t quiz-backend:avant ./backend
docker build -t quiz-frontend:avant .
docker images | grep quiz-`

`docker build` permet de fabriquer une image à partir d'un dockerfile
`-t quiz-backend:avant` permet de donner un nom à l'image et un tag
`./backend` indique le dossier qui contient le dockerfile du backend
`docker images | grep quiz-`permet de verifier que les deux images existent bien et note leur taille.

2.2 premier Scan Trivy

trivy image --severity LOW,MEDIUM,HIGH,CRITICAL -o docs/trivy/backend-avant.txt  quiz-backend:avant
trivy image --severity LOW,MEDIUM,HIGH,CRITICAL -o docs/trivy/frontend-avant.txt quiz-frontend:avant
trivy config -o docs/trivy/config-avant.txt .

`trivy image`analyse tous les paquets contenus dans l'image comme les paquets linux alpine et les paquets npm

``--severity` indique les niveaux de gravité à inclure dans le rapport

`- fichier.txt`enregistre le résultat dans un fichier au lieu de l'afficher, c'est la preuve de l'avant.

`trivy config` permet d'analyser les dockerfiles et signale les mauvaise pratiques, comme une image qui tourne en root ou l'absence de Healthcheck.

resultats : 
```-11-26T10:44:49Z        INFO    [vulndb] Artifact successfully downloaded       repo="mirror.gcr.io/aquasec/trivy-db:2"
2026-11-26T10:44:49Z    INFO    [vuln] Vulnerability scanning is enabled
2026-11-26T10:44:49Z    INFO    [secret] Secret scanning is enabled
2026-11-26T10:44:49Z    INFO    [secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2026-11-26T10:44:49Z    INFO    [secret] Please see https://trivy.dev/docs/v0.76/guide/scanner/secret#recommendation for faster secret detection
2026-11-26T10:44:50Z    INFO    Detected OS     family="alpine" version="3.24.4"
2026-11-26T10:44:50Z    INFO    [alpine] Detecting vulnerabilities...   os_version="3.24" repository="3.24" pkg_num=19
2026-11-26T10:44:50Z    INFO    Number of language-specific files       num=1
2026-11-26T10:44:50Z    INFO    [node-pkg] Detecting vulnerabilities...
2026-11-26T10:44:50Z    WARN    Using severities from other vendors for some vulnerabilities. Read https://trivy.dev/docs/v0.76/guide/scanner/vulnerability#severity-selection for details.
2026-11-26T10:44:50Z    INFO    Table result includes only package filenames. Use '--format json' option to get the full path to the package file.
2026-11-26T10:44:51Z    INFO    [vuln] Vulnerability scanning is enabled
2026-11-26T10:44:51Z    INFO    [secret] Secret scanning is enabled
2026-11-26T10:44:51Z    INFO    [secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2026-11-26T10:44:51Z    INFO    [secret] Please see https://trivy.dev/docs/v0.76/guide/scanner/secret#recommendation for faster secret detection
2026-11-26T10:44:51Z    INFO    Detected OS     family="alpine" version="3.24.4"
2026-11-26T10:44:51Z    INFO    [alpine] Detecting vulnerabilities...   os_version="3.24" repository="3.24" pkg_num=72
2026-11-26T10:44:51Z    INFO    Number of language-specific files       num=0
2026-11-26T10:44:51Z    WARN    Using severities from other vendors for some vulnerabilities. Read https://trivy.dev/docs/v0.76/guide/scanner/vulnerability#severity-selection for details.
2026-11-26T10:44:52Z    INFO    [misconfig] Misconfiguration scanning is enabled
2026-11-26T10:44:52Z    INFO    [checks-client] Need to update the checks bundle
2026-11-26T10:44:52Z    INFO    [checks-client] Downloading the checks bundle...```

pour avoir un report de tout ce que je viens de faire juste au dessus on peut utiliser cette commande :

grep "^Total" docs/trivy/*-avant.txt
trivy image --severity HIGH,CRITICAL quiz-backend:avant
trivy image --severity HIGH,CRITICAL quiz-frontend:avant

la premiere commande permet d'afficher le nombre de vulnérabilités par niveau de gravité pour chaque image.

Les deux suivantes affichent à l'écran seulement les vulnérabilitées graves.


le report est aussi mit dans docs/trivy/backend-avant.txt

2.3 durcir l'image backend



docker build --pull --no-cache -t quiz-backend:apres ./backend

permet de recuperer la derniere version de node:22-alpine.
--no-cache force docker à réexécuter apk upgrade au lieu de réutiliser un ancien résultat.

docker run --rm --entrypoint sh quiz-backend:apres -c "whoami; which npm || echo 'npm absent'"

cette commande prouve que l'image tourne en utilisateur "node" et que npm a bien été supprimé.

trivy image --severity LOW,MEDIUM,HIGH,CRITICAL -o docs/trivy/backend-apres.txt quiz-backend:apres
grep "^Total" docs/trivy/backend-apres.txt

voir report dans el backend-apres.txt pour bien voir que il reste plus que 2 vulnérabilités (glob et minimatch).

2.4 verifications

docker build --pull --no-cache -t quiz-frontend:apres .
docker run --rm --entrypoint sh quiz-frontend:apres -c "whoami"

cette commande permet de verifier si le user est bien nginx et pas root

trivy image --severity LOW,MEDIUM,HIGH,CRITICAL -o docs/trivy/frontend-apres.txt quiz-frontend:apres
trivy config -o docs/trivy/config-apres.txt .
grep "^Total\|^Failures" docs/trivy/*-apres.txt

cette commande permet de voir si il y a des vulnérabilités sur le frontend et si il y a des failures sur les deux dockerfiles.


