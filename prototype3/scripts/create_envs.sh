#!/bin/bash
set -e

echo "======================================="
echo "🔐 Creating .env files for local setup"
echo "======================================="

# --- Authentication Service ---
mkdir -p authentication-service
cat > authentication-service/.env <<EOF
FIREBASE_CREDENTIALS_JSON=firebase-credentials-here

API_KEY=your_api_key_here
EOF

# --- Route Service ---
mkdir -p route-service
cat > route-service/.env.development <<EOF
DB_HOST=postgres
DB_PORT=5432
DB_USER=routes_user
DB_PASSWORD=routes_password
DB_NAME=routes_db

# Application Configuration
PORT=3000
NODE_ENV=development
AUTH_SERVICE_JWT_SECRET=SECRET_KEY
CALCULATION_SERVICE_URL=//api-gateway:8888/distanceApi/graphql
AUTH_SERVICE_URL=http://api-gateway:8888/authApi/graphql



# RabbitMQ Configuration
RABBITMQ_URL=amqp://guest:guest@rabbit:5672

# Configuración del Exchange (debe coincidir con Spring)
RABBITMQ_EXCHANGE=notification-exchange

# Tipo de exchange (topic , direct)
RABBITMQ_EXCHANGE_TYPE=direct

# Routing Key (debe coincidir con Spring)
RABBITMQ_ROUTING_KEY=notification-routing-key

# Configuración de reconexión
RABBITMQ_MAX_RECONNECT_ATTEMPTS=5
RABBITMQ_RECONNECT_DELAY=5000
EOF

# --- Frontend SSR ---
mkdir -p frontend-ssr
cat > frontend-ssr/.env <<EOF
API_GATEWAY=http://api-gateway:8888
AUTH_SERVICE=authApi/graphql
DISTANCE_SERVICE=distanceApi
ROUTES_SERVICE=routesApi/routes
PORT=3001
NEXT_PUBLIC_MAPBOX_TOKEN='your_mapbox_token_here'
EOF

# --- Notification Service ---
mkdir -p notification-service
cat > notification-service/.env <<EOF
SPRING_MAIL_USERNAME= your_email_here
SPRING_MAIL_PASSWORD= your_email_application_password_here
EOF

mkdir -p notification-service
cat > notification-service/application.properties <<EOF
spring.application.name=notification-service
server.port=8085
# RabbitMQ Configuration
spring.rabbitmq.host=rabbit
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest
#SMTP configuration
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=${SPRING_MAIL_USERNAME}
spring.mail.password=${SPRING_MAIL_PASSWORD}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
graphql.endpoint=http://api-gateway:8888/authApi/graphql
# Scheduler configuration
# Cron format: segundo minuto hor   a dia mes dia-semana
# Ejemplo: "0 0 10 * * *" = todos los d�as a las 10:00 AM
# Ejemplo: "0 */5 * * * *" = cada 5 minutos (para pruebas)
scheduler.engagement.cron=0 */5 * * * *

EOF

# --- API Gateway Service ---
mkdir -p runpath-api-gateway
cat > runpath-api-gateway/.env << EOF
AUTH_HOST=load-balancer-auth
AUTH_PORT=9001
DISTANCE_HOST=osrm-colombia
DISTANCE_PORT=5002
ROUTES_HOST=routes_app
ROUTES_PORT=3000
GOOGLE_APPLICATION_CREDENTIALS=./app/firebase-key.json
EOF

mkdir -p runpath-api-gateway/api-gateway/app
cat > runpath-api-gateway/api-gateway/app/firebase-key.json <<EOF
your_firebase_key_here

EOF

echo "✅ All .env files created!"
