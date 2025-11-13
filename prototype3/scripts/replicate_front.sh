#!/bin/bash
set -e

echo "======================================="
echo "🚀 Deploying Frontend SSR Replicas"
echo "======================================="


# Navegar al directorio del frontend
cd frontend-ssr

# Construir la imagen base
echo "📦 Building frontend-ssr image..."
docker build -t frontend-ssr:latest .

# Definir las réplicas según nginx.conf
declare -A replicas=(
  ["frontend-ssr-1"]="3002"
  ["frontend-ssr-2"]="3003"
)

# Detener y eliminar contenedores anteriores
echo "🧹 Cleaning up old containers..."
for container in "${!replicas[@]}"; do
  docker stop "$container" 2>/dev/null || true
  docker rm "$container" 2>/dev/null || true
done

# Crear y arrancar cada réplica
echo "🎭 Starting replicas..."
for container in "${!replicas[@]}"; do
  port="${replicas[$container]}"
  
  echo "  ├─ Starting $container on port $port..."
  
  docker run -d \
    --name "$container" \
    --env-file .env \
    -e PORT="$port" \
    --network frontend_net \
    --network orchestration_net \
    --restart unless-stopped \
    frontend-ssr:latest
  
  echo "  └─ ✅ $container started successfully"
done

echo ""
echo "======================================="
echo "✅ All replicas deployed successfully!"
echo "======================================="
echo "Replicas running:"
for container in "${!replicas[@]}"; do
  port="${replicas[$container]}"
  echo "  • $container -> internal port $port"
done
echo ""
echo "Access via reverse proxy: https://localhost"
echo "======================================="