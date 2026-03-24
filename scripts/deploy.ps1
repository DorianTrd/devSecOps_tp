$ErrorActionPreference = "Stop"

$GITHUB_SHA = $env:GITHUB_SHA
$USERNAME = $env:DOCKERHUB_USERNAME

# 1. Lire la couleur active actuelle
$activeColorFile = "./nginx/active_color.txt"
$activeColorContent = Get-Content $activeColorFile -Raw

if ($activeColorContent -match "backend_blue") {
    $activeColor = "blue"
    $inactiveColor = "green"
} else {
    $activeColor = "green"
    $inactiveColor = "blue"
}

Write-Host "🔵🟢 Couleur active : $activeColor → Déploiement sur : $inactiveColor"

# 2. Pull des nouvelles images (couleur inactive)
Write-Host "⬇️ Pull des images $inactiveColor..."
docker pull "$USERNAME/cloudnative-backend-$inactiveColor`:$GITHUB_SHA"
docker pull "$USERNAME/cloudnative-frontend-$inactiveColor`:$GITHUB_SHA"

# 3. Déployer la nouvelle version sur la couleur inactive (sans toucher l'active)
Write-Host "🚀 Déploiement de la version $inactiveColor..."
docker compose -f docker-compose.base.yml -f "docker-compose.$inactiveColor.yml" up -d --no-recreate

# Attendre que les conteneurs soient up
Start-Sleep -Seconds 15

# 4. Vérifier que la nouvelle version est healthy
$backContainer = "app-back-$inactiveColor"
$running = docker ps -q -f "name=$backContainer"
if (-not $running) {
    Write-Error "❌ Le backend $inactiveColor n'a pas démarré. Rollback annulé, l'ancienne version ($activeColor) reste active."
    exit 1
}

# 5. Basculer le reverse proxy vers la nouvelle couleur
Write-Host "🔀 Bascule du proxy vers $inactiveColor..."
Set-Content $activeColorFile "set `$active_backend `"backend_$inactiveColor`";`nset `$active_frontend `"frontend_$inactiveColor`";"

# 6. Recharger Nginx sans downtime
docker exec $(docker ps -q -f "name=reverse-proxy") nginx -s reload

Write-Host "✅ Bascule effectuée ! Version active : $inactiveColor"
Write-Host "ℹ️  Pour rollback : relancer le pipeline ou exécuter scripts/rollback.ps1"

docker compose ps