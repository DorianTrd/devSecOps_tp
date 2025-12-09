set -e

GITHUB_SHA=${GITHUB_SHA:-latest}
USERNAME=${DOCKERHUB_USERNAME:-"<username>"}

echo "🛑 Arrêt des conteneurs existants..."
docker compose down

echo "⬇️ Pull des dernières images..."
docker pull $USERNAME/cloudnative-backend:$GITHUB_SHA
docker pull $USERNAME/cloudnative-frontend:$GITHUB_SHA

echo "🔄 Redémarrage de l'environnement..."
docker compose up -d

echo "✅ Déploiement terminé !"
docker compose ps
