#!/bin/bash
set -e

echo "======================================="
echo "📦 Cloning all repositories..."
echo "======================================="

repos=(
  "https://github.com/ArquiSoft-Grupo-2B/distance-repository.git"
  "https://github.com/ArquiSoft-Grupo-2B/route-service.git"
  "https://github.com/ArquiSoft-Grupo-2B/authentication-service.git"
  "https://github.com/ArquiSoft-Grupo-2B/frontend-ssr.git"
  "https://github.com/ArquiSoft-Grupo-2B/notification-service.git"
  "https://github.com/ArquiSoft-Grupo-2B/logs-service.git"
  "https://github.com/ArquiSoft-Grupo-2B/front-mobile.git"
  "https://github.com/ArquiSoft-Grupo-2B/runpath-api-gateway.git"
  "https://github.com/ArquiSoft-Grupo-2B/web-reverse-proxy.git"
  "https://github.com/ArquiSoft-Grupo-2B/mobile-reverse-proxy.git"
  "https://github.com/ArquiSoft-Grupo-2B/load-balancer-auth.git"
)

for repo in "${repos[@]}"; do
  name=$(basename "$repo" .git)
  if [ ! -d "$name" ]; then
    echo "⬇️ Cloning $name ..."
    git clone "$repo"
  else
    echo "✅ $name already exists, skipping."
  fi
done

echo "✅ Repositories cloned"
