$ErrorActionPreference = "Stop"

$activeColorFile = "./nginx/active_color.txt"
$activeColorContent = Get-Content $activeColorFile -Raw

if ($activeColorContent -match "backend_blue") {
    $rollbackColor = "green"
} else {
    $rollbackColor = "blue"
}

Write-Host "⏪ Rollback vers $rollbackColor..."

Set-Content $activeColorFile "set `$active_backend `"backend_$rollbackColor`";`nset `$active_frontend `"frontend_$rollbackColor`";"

docker exec $(docker ps -q -f "name=reverse-proxy") nginx -s reload

Write-Host "✅ Rollback effectué ! Version active : $rollbackColor"