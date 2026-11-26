# Jalon 0

Vérification de la connectivité Azure et de la fonctionnalité : OK

# Jalon 1

1.1

Lancement de l'application Docker Desktop.

Lancement OK, vérification avec la commande `docker info`.
Retour de la commande :

"$ docker info
Client:
 Version:    29.9.1
 Context:    desktop-linux
 Debug Mode: false
 Plugins:
  agent: Docker AI Agent Runner (Docker Inc.)
    Version:  v1.149.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-agent.exe
  ai: Docker AI Agent - Ask Gordon (Docker Inc.)
    Version:  v1.31.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-ai.exe
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.38.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-buildx.exe
  compose: Docker Compose (Docker Inc.)
    Version:  v5.6.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-compose.exe
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.0.47
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-debug.exe
  desktop: Docker Desktop commands (Docker Inc.)
    Version:  4.96.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-desktop.exe
  dhi: CLI for managing Docker Hardened Images (Docker Inc.)
    Version:  v0.0.7
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-dhi.exe
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.31
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-extension.exe
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.4.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-init.exe
  mcp: Docker MCP Plugin (Docker Inc.)
    Version:  v0.44.1
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-mcp.exe
  model: Docker Model Runner (Docker Inc.)
    Version:  v1.2.6
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-model.exe
  offload: Docker Offload (Docker Inc.)
    Version:  v0.7.4
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-offload.exe
  pass: Docker Pass Secrets Manager Plugin (beta) (Docker Inc.)
    Version:  v0.3.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-pass.exe
  sandbox: "docker sandbox" is deprecated, use Docker Sandboxes instead (Docker Inc.)
    Version:  v0.13.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-sandbox.exe
  scout: Docker Scout (Docker Inc.)
    Version:  v1.26.0
    Path:     C:\Users\Morgan\.docker\cli-plugins\docker-scout.exe

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 24
 Server Version: 29.9.1
 Storage Driver: overlayfs
  driver-type: io.containerd.snapshotter.v1
 Logging Driver: local
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Discovered Devices:
  cdi: docker.com/gpu=webgpu
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 nvidia runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: b7a25261e029d68978bbf290df0a62fc819b3c51
 runc version: v1.5.2-0-g29dd3dc2
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 6.18.58.1-microsoft-standard-WSL2
 Operating System: Docker Desktop
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 3.703GiB
 Name: docker-desktop
 ID: c0db8cb2-20e1-4290-be4b-2a5a9f340e70
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 HTTP Proxy: http.docker.internal:3128
 HTTPS Proxy: http.docker.internal:3128
 No Proxy: hubproxy.docker.internal
 Labels:
  com.docker.desktop.address=npipe://\\.\pipe\docker_cli
 Experimental: false
 Insecure Registries:
  hubproxy.docker.internal:5555
  127.0.0.0/8
  ::1/128
 Live Restore Enabled: false
 Firewall Backend: iptables"

 1.2 Création de branche de travail

 Création d'une branche de travail par jalon. Ici création pour la branche du J1 `git checkout -b feature/J1-conteneurisation` 

 1.3 

 Création du fichier "package-lock.json". Permet de noter la version exacte de chaque bibliothèque : `npm install --package-lock-only`

 Cela permet de "verrouiller" les versions en cours d'utilisation.

 Création du Dockerfile : tout est documenté dans le Dockerfile via des commentaires.

 Création du .dockerignore

 Construction et test du conteneur : `docker build -t quiz-backend ./`

 "$ docker build -t quiz-backend ./
[+] Building 10.2s (10/10) FINISHED                                                                                   docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                  0.3s
 => => transferring dockerfile: 623B                                                                                                  0.0s
 => [internal] load metadata for docker.io/library/node:22-alpine                                                                     0.0s
 => [internal] load .dockerignore                                                                                                     0.1s
 => => transferring context: 58B                                                                                                      0.0s
 => [1/5] FROM docker.io/library/node:22-alpine@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a               0.1s
 => => resolve docker.io/library/node:22-alpine@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a               0.1s
 => [internal] load build context                                                                                                     0.1s
 => => transferring context: 91.53kB                                                                                                  0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                         0.0s
 => [3/5] COPY package.json package-lock.json ./                                                                                      0.1s
 => [4/5] RUN npm ci --omit=dev                                                                                                       6.6s
 => [5/5] COPY server.js ./                                                                                                           0.1s
 => exporting to image                                                                                                                2.6s
 => => exporting layers                                                                                                               1.4s
 => => exporting manifest sha256:eaec3d98f773f7a60b41bcd8e3471340ec711c851643e6e0bde756f8d406f1d6                                     0.0s
 => => exporting config sha256:f3c4e2c763fe19a824790459025b68ccf6dbc280609b456459d0c8d8d656ee68                                       0.0s
 => => exporting attestation manifest sha256:3c09f98fe674b1e1a6b9385c064132cc1b2e8c876c7d560416b558e24f0e062c                         0.0s
 => => exporting manifest list sha256:c478ffa3b245a4db071f947f1e5737e121385a0795dd5e05c8992c8fe756706b                                0.0s
 => => naming to docker.io/library/quiz-backend:latest                                                                                0.0s
 => => unpacking to docker.io/library/quiz-backend:latest                                                                             1.0s"

Build OK

Ensuite, `docker run -d --rm -p 3007:3007 -e RESEND_API_KEY=re_dummy quiz-backend`

Le conteneur tourne, ne pas oublier `-d`

Penser à nommer le conteneur également `--name`

Pour tester, on tape l'url suivante : "http://localhost:3007/health" et on a ce retour "{"status":"ok"}" donc tout est bon !

1.4 Frontend

Le Backend étant plus ou moins fonctionnel, on va s'occuper du Frontend (ce que l'utilisateur voit)

Création d'un nouveau Dockerfile `projetconteneurisation/eval-quiz-app/Dockerfile`
Les informations relatives aux lignes de code sont ajoutées directement dans le Dockerfile sous forme de commentaire

Création du .dockerignore

Construction de l'image `docker build -t quiz-frontend .`

"$ docker build -t quiz-frontend .
[+] Building 11.2s (15/15) FINISHED                                                                                   docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                  0.1s
 => => transferring dockerfile: 612B                                                                                                  0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                                       0.1s
 => [internal] load metadata for docker.io/library/node:22-alpine                                                                     0.1s
 => [internal] load .dockerignore                                                                                                     0.1s
 => => transferring context: 85B                                                                                                      0.0s
 => [build 1/6] FROM docker.io/library/node:22-alpine@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a         0.1s
 => => resolve docker.io/library/node:22-alpine@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a               0.1s
 => [internal] load build context                                                                                                     0.3s
 => => transferring context: 289.67kB                                                                                                 0.2s
 => [stage-1 1/3] FROM docker.io/library/nginx:alpine@sha256:b50897d5c7b1aa08067c3d90c5e8b3e47ec4e3c91c91446f67820228f7b41e34         2.7s
 => => resolve docker.io/library/nginx:alpine@sha256:b50897d5c7b1aa08067c3d90c5e8b3e47ec4e3c91c91446f67820228f7b41e34                 0.1s
 => => extracting sha256:272cbe758287982b2c7b62a27569df2d74716fdea812b4b3573dab2658c8ddbe                                             0.6s
 => => extracting sha256:fbbe454312b97bc348f30147303ed234da7a58f6ccda9c7d390e2bbdc8ff85ea                                             0.1s
 => => extracting sha256:96001c9779a126dfde151a983697b92e22f24f24d05f8afbadcda643a98c55da                                             0.1s
 => => extracting sha256:85b05bfd25bc068837a4ecb73f940ce6252369eea7cd8c3660d4d5354db76a86                                             0.1s
 => => extracting sha256:e9820988621b9d4f3f959b73badb1d607f93da221e42eb4a5d30c5301f70bc60                                             0.0s
 => => extracting sha256:3623869d224d7166e17864edf35efe7a597df1f3a04e68d17c745b903c00bcda                                             0.0s
 => => extracting sha256:e5f8fe67c1e12b44e2c94d2a3d28ab9dc50d18231a774cb5809f9a00f1f13c7e                                             1.4s
 => CACHED [build 2/6] WORKDIR /app                                                                                                   0.0s
 => [build 3/6] COPY package.json package-lock.json ./                                                                                0.1s
 => [build 4/6] RUN npm ci                                                                                                            7.5s
 => [stage-1 2/3] COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf                                                                0.2s
 => [build 5/6] COPY . .                                                                                                              0.1s
 => [build 6/6] RUN npm run build                                                                                                     1.9s
 => [stage-1 3/3] COPY --from=build /app/dist /usr/share/nginx/html                                                                   0.1s
 => exporting to image                                                                                                                0.6s
 => => exporting layers                                                                                                               0.2s
 => => exporting manifest sha256:e6319755799610736091ef462726ff83d2a7c6bcc9cfadb507fe0c11bda89130                                     0.0s
 => => exporting config sha256:d6258e53a4ce65ea87c1c9bfab96a0345872345e140d3da3ca634e0b7109fd0b                                       0.0s
 => => exporting attestation manifest sha256:489544e7cd985de06de07cddbcb650a73737f6038718281bd64289e13e735a21                         0.0s
 => => exporting manifest list sha256:f35a573ff947956aa02330ed8e8f8b797fac93a21335d0e70cd23e5943cb0ad6                                0.0s
 => => naming to docker.io/library/quiz-frontend:latest                                                                               0.0s
 => => unpacking to docker.io/library/quiz-frontend:latest                                                                            0.1s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/l5gff7nb1otxjpz27kgp2y7ym"

Test : `docker run --rm -p 8087:80 quiz-frontend`

"$ docker run --rm -p 8087:80 quiz-frontend
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: /etc/nginx/conf.d/default.conf differs from the packaged version
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/11/26 09:50:59 [emerg] 1#1: host not found in upstream "backend:3007" in /etc/nginx/conf.d/default.conf:3
nginx: [emerg] host not found in upstream "backend:3007" in /etc/nginx/conf.d/default.conf:3

What's next:
    Debug this container error with Gordon → docker ai "help me fix this container error""

Erreur normale, puisque Nginx envoie ses appels à la machine "backend" qui n'existe pas. Il n'y a qu'un seul conteneur Frontend, d'où l'intérêt d'utiliser "Docker Compose".


