$ErrorActionPreference = "Stop"

$GITHUB_SHA = $env:GITHUB_SHA
$USERNAME = $env:DOCKERHUB_USERNAME

# 1. Read current active color
$activeColorFile = "./nginx/active_color.txt"
$activeColorContent = Get-Content $activeColorFile -Raw

if ($activeColorContent -match "backend_blue") {
    $activeColor = "blue"
    $inactiveColor = "green"
} else {
    $activeColor = "green"
    $inactiveColor = "blue"
}

Write-Host "Active color: $activeColor -> Deploy target: $inactiveColor"

# 2. Pull images for inactive color
Write-Host "Pull images for $inactiveColor..."
docker pull "$USERNAME/cloudnative-backend-$inactiveColor`:$GITHUB_SHA"
docker pull "$USERNAME/cloudnative-frontend-$inactiveColor`:$GITHUB_SHA"

# 3. Deploy inactive color without touching active one
Write-Host "Deploy $inactiveColor..."
docker compose -f docker-compose.base.yml -f "docker-compose.$inactiveColor.yml" up -d --no-recreate

# Wait until containers are up
Start-Sleep -Seconds 15

# 4. Verify deployed backend is running
$backContainer = "app-back-$inactiveColor"
$running = docker ps -q -f "name=$backContainer"
if (-not $running) {
    Write-Error "Backend $inactiveColor did not start. Active version remains $activeColor."
    exit 1
}

# 5. Switch reverse proxy to inactive color
Write-Host "Switch proxy to $inactiveColor..."
Set-Content -Path $activeColorFile -Value @(
    "set `$active_backend `"backend_$inactiveColor`";",
    "set `$active_frontend `"frontend_$inactiveColor`";"
)

# 6. Reload Nginx without downtime
$proxyContainerId = docker ps -q -f "name=reverse-proxy"
if (-not $proxyContainerId) {
    Write-Error "Reverse proxy container not found."
    exit 1
}
docker exec $proxyContainerId nginx -s reload

Write-Host "Switch done. Active version: $inactiveColor"
Write-Host "For rollback run scripts/rollback.ps1"

docker compose ps