#!/bin/bash
set -e

echo "======================================="
echo "🚀 Deploying Auth Service Replicas"
echo "======================================="


# Navegar al directorio del auth-service
cd authentication-service

# Construir la imagen base
echo "📦 Building authentication-service image..."
docker build -t authentication-service:latest .
# Definir las réplicas según nginx.conf
declare -A replicas=(
  ["authentication-service-1"]="8001"
  ["authentication-service-2"]="8002"
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
    --network backend_net \
    --network db_net \
    --restart unless-stopped \
    authentication-service:latest
  
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
