$ErrorActionPreference = "Stop"

$GITHUB_SHA = $env:GITHUB_SHA
$USERNAME = $env:DOCKERHUB_USERNAME

Write-Host "🛑 Arrêt des conteneurs existants..."
docker compose down

Write-Host "⬇️ Pull des dernières images..."
docker pull "$USERNAME/cloudnative-backend:$GITHUB_SHA"
docker pull "$USERNAME/cloudnative-frontend:$GITHUB_SHA"

Write-Host "🔄 Redémarrage de l'environnement..."
docker compose up -d

Write-Host "✅ Déploiement terminé !"
docker compose ps