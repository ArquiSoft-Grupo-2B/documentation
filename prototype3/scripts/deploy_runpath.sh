#!/bin/bash

# ======================================
# RunPath - Flexible Deployment Script
# ======================================
# Author: Grupo 2B
# Description: Deploy one or multiple RunPath services using Docker
# ======================================

set -e  # Stop on first error

# --- Services and deployment commands ---
declare -A services=(
  ["runpath-api-gateway"]="docker compose up --build -d"
  ["authentication-service"]="docker compose up --build -d"
  ["notification-service"]="docker compose up --build -d"
  ["distance-repository"]="docker compose up --build -d"
  ["route-service"]="npm run docker:dev"
  ["frontend-ssr"]="docker compose up --build -d"
  ["logs-service"]="docker compose up --build -d"
  ["web-reverse-proxy"]="docker compose up --build -d"
  ["load-balancer-auth"]="docker compose up --build -d"
  ["mobile-reverse-proxy"]="docker compose up --build -d"
)

# --- Deployment order ---
ordered_services=(
  "notification-service"
  "runpath-api-gateway"
  "authentication-service"
  "distance-repository"
  "frontend-ssr"
  "route-service"
  "web-reverse-proxy"
  "mobile-reverse-proxy"
  "load-balancer-auth"
  "logs-service"
)

create_networks() {
  echo "🕸️ Checking required Docker networks..."

  declare -A NETWORK_SUBNETS=(
    ["public_net"]="172.26.0.0/16"
    ["frontend_net"]="172.27.0.0/16"
    ["orchestration_net"]="172.29.0.0/16"
    ["backend_net"]="172.28.0.0/16"
    ["db_net"]="172.30.0.0/16"
  )

  for net in "${!NETWORK_SUBNETS[@]}"; do
    subnet="${NETWORK_SUBNETS[$net]}"

    if ! docker network ls | grep -q "$net"; then
      echo "🔧 Creating network: $net ($subnet)"
      docker network create --driver bridge --internal --subnet "$subnet" "$net"
    else
      echo "✅ Network '$net' already exists."
    fi
  done
}


check_env() {
  local dir=$1
  # Servicios que no requieren .env
  if [[ "$dir" == "distance-repository" || "$dir" == "logs-service" || "$dir" == "web-reverse-proxy" || "$dir" == "mobile-reverse-proxy" || "$dir" == "load-balancer-auth" ]]; then
    return 0
  fi

  if [ -f "$dir/.env" ] || [ -f "$dir/.env.development" ]; then
    echo "✅ Found .env file in $dir"
    return 0
  else
    echo "❌ No .env file found in $dir — skipping deployment!"
    return 1
  fi
}


deploy_service() {
  local dir=$1
  local cmd=$2

  echo ""
  echo "======================================="
  echo "▶️ Deploying: $dir"
  echo "======================================="

  if [ ! -d "$dir" ]; then
    echo "❌ Directory $dir not found, skipping."
    return
  fi

  if check_env "$dir"; then
    cd "$dir"
    eval $cmd
    
    cd ..
    echo "✅ $dir started successfully!"
    
    # Deploy frontend-ssr replicas after original container
    if [ "$dir" == "frontend-ssr" ]; then
      echo ""
      echo "🔄 Deploying frontend-ssr replicas..."
      ./replicate_front.sh
    fi

    if [ "$dir" == "authentication-service" ]; then
      echo ""
      echo "🔄 Deploying authentication-service replicas..."
      ./replicate_auth.sh
    fi
  else
    echo "⚠️ Skipped $dir (missing .env)"
  fi
}

# --- Parse arguments ---
selected_services=()

if [ "$1" == "--only" ]; then
  shift
  while [ $# -gt 0 ]; do
    selected_services+=("$1")
    shift
  done
elif [ "$1" == "--all" ] || [ $# -eq 0 ]; then
  selected_services=("${ordered_services[@]}")
else
  echo "❌ Invalid parameter. Use:"
  echo "   ./deploy_runpath.sh --all          # Deploy everything"
  echo "   ./deploy_runpath.sh --only <svc1> <svc2> ..."
  exit 1
fi

# --- Start deployment ---
echo "======================================="
echo "🚀 Starting RunPath deployment..."
echo "======================================="

create_networks

for svc in "${selected_services[@]}"; do
  if [[ -n "${services[$svc]}" ]]; then
    deploy_service "$svc" "${services[$svc]}"
  else
    echo "⚠️ Unknown service: $svc"
  fi
done

echo ""
echo "======================================="
echo "🎉 Deployment completed!"
echo "======================================="
echo "🌐 Entrypoint (Web): https://localhost"
echo "🌐 Entrypoint (Mobile): https://localhost:8443"
echo "======================================="
