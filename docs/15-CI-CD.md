# Jalon 6

6.0 : fichier du workflow

cd ~/Documents/containers/eval-quiz-app
mkdir -p .github/workflows
touch .github/workflows/ci.yml

Github actions lit automatiquement tous les fichiers .yml du dossier .github/workflows/.

docker run --rm -v "$PWD":/work -w /work rhysd/actionlint:1.7.7 .github/workflows/ci.yml && echo "YAML OK"

permet de tester le fichier YAML.

Resultat : YAML OK