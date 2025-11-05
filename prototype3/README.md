<p align="center">
<img src="./imgs/UNAL.png" width="200">
</p>
<h2 align="center"><small>Prototype 3</small></br> <big>RunPath</big></br>Team 2B</h2>

---

# Team
- Samuel Josué Vargas Castro
- Daniel Felipe Soracipa
- Juan Esteban Cárdenas Huertas
- Juan David Ardila Diaz
- Martin Moreno Jara
- Juan José Medina Guerrero
- Sergio Enrique Vargas Pedraza

# Software System

## Run Path

<p align="center">
<img src="./imgs/Logo.png" width="100">
</p>

RunPath is a platform that helps users discover nearby jogging routes throughout the city of Bogotá.
By using their current location, users can explore an interactive map that displays the closest jogging paths and view detailed information such as total distance, estimated duration, and route layout. The system also allows users to receive personalized notifications and reminders to stay active.

Available both on the web and as a mobile application, RunPath provides a simple and engaging way to promote outdoor exercise and healthy habits in urban environments.

# Architectural Structures

## Component and Connector (C&C) Structure

### C&C View

<p align="center">
<img src="./imgs/cc_view_prototype2.svg">
</p>

### Components Description

#### `runpath-frontend-ssr`
- **Technology:** React + Next.js (JavaScript)
- **Description:** RunPath system's web interface that allows users to register, log in, view available routes, and check their progress. It communicates with the API Gateway to consume backend services.

---

#### `runpath-mobile`
- **Technology:** Kotlin (Jetpack Compose)
- **Description:** RunPath's native mobile application that replicates and complements the web frontend's functionality. It provides an optimized experience for Android devices and communicates with the API Gateway for all operations.

---

#### `runpath-login`
- **Technology:** Python (FastAPI)
- **Description:** Service responsible for authentication and user management of the RunPath system. It exposes its functionalities through the API Gateway.

---

#### `runpath-routes`
- **Technology:** Node.js (Express)
- **Description:** Microservice responsible for **route management**. It handles route creation and management. It also allows users to track and finalize routes.

---

#### `runpath-distance`
- **Technology:** Python (FastAPI)
- **Description:** Service responsible for calculating distances between geographical points and analyzing route-related metrics. It communicates with other services through the API Gateway.

---

#### `runpath-notifications`
- **Technology:** Java (Spring Boot)
- **Description:** Microservice responsible for sending email notifications and reminders to users. It processes messages coming from the RabbitMQ broker (emitted by `runpath-routes`) and generates additional scheduled notifications.

---

#### `runpath-broker`
- **Technology:** RabbitMQ
- **Description:** Messaging middleware that acts as an asynchronous intermediary between `runpath-routes` and `runpath-notifications`. It receives route completion events and delivers them for subsequent processing and user notification.

---

#### `API Gateway`
- **Technology:** Express Gateway
- **Description:** Unified entry point that manages requests coming from clients (frontend and mobile). It is responsible for orchestrating requests to the internal microservices, handling authentication and authorization.

---

#### Summary Table — Components Overview

| **Component** | **Technology** | **Primary Responsibility** | **Key Interactions** |
|:---:|:---:|:---:|:---:|
| `runpath-frontend-ssr` | React + Next.js (JavaScript) | Web system interface; allows users to log in, register, and view routes. | Communicates with the API Gateway via HTTP/HTTPS. |
| `runpath-mobile` | Kotlin (Jetpack Compose) | Native mobile application replicating web frontend functionalities and enabling route tracking and finalization. | Communicates with the API Gateway via HTTP/HTTPS. |
| `runpath-login` | Python (FastAPI) | Authentication and user management. | Connected to the API Gateway via GraphQL. |
| `runpath-routes` | Node.js (Express) | Route management (creation, tracking, finalization). | Communicates with `runpath-distance` via API Gateway and publishes messages to RabbitMQ. |
| `runpath-distance` | Python (FastAPI) | Calculation of distances and geographical metrics. | Communicates with `runpath-routes` through the API Gateway. |
| `runpath-notifications` | Java (Spring Boot) | Sending email notifications and reminders. | Consumes messages from RabbitMQ and sends emails to users. |
| `runpath-broker` | RabbitMQ | Asynchronous message queue between routes and notifications. | Receives events from `runpath-routes` and distributes them to `runpath-notifications`. |
| `API Gateway` | Express Gateway | Unified entry point; manages authentication and routes requests. | Connects clients (web and mobile) with all backend microservices. |

### Connector Description

#### Authentication Service Connectors

1. **Connector to Firebase Authentication via SDK**
   - **Components:** runpath-login (FastAPI) ↔ firebase-authentication (Firebase)
   - **Protocol:** Firebase SDK
   - **Communication:** Client → Server, Synchronous Request/Response

2. **REST Connector with Firebase Authentication (Firebase Auth REST API)**
   - **Components:** runpath-login (FastAPI) ↔ firebase-authentication (Firebase)
   - **Protocol:** HTTP/REST
   - **Communication:** Client → Server, Synchronous Request/Response

3. **Connector to Document NoSQL Database**
   - **Components:** firebase-authentication (Firebase) ↔ user-db (Firebase Service)
   - **Protocol:** Firebase Native Connectors
   - **Communication:** Client → Server, Synchronous Request/Response

---

#### Routes Service Connectors

1. **TCP Connector to Relational Database**
   - **Components:** runpath-routes (Node.js) ↔ geography-db (PostgreSQL + PostGIS)
   - **Protocol:** TypeORM over TCP/PostgreSQL
   - **Communication:** Client → Server, Synchronous Request/Response

2. **AMQP Connector with Messaging Broker**
   - **Components:** runpath-routes (Node.js) → runpath-broker (RabbitMQ)
   - **Protocol:** AMQP
   - **Communication:** Unidirectional, Asynchronous Communication (publish)

---

#### Presentation Service Connectors (Frontend and Mobile)

1. **HTTP Connector with API Gateway**
   - **Components:** runpath-frontend (Next.js) ↔ API Gateway (Express Gateway)
   - **Protocol:** HTTP
   - **Communication:** Client → Server, Synchronous Request/Response
   - **Description:** Allows the web interface to interact with the system's microservices through the gateway.

2. **HTTP Connector with API Gateway (Mobile)**
   - **Components:** runpath-mobile (Kotlin) ↔ API Gateway (Express Gateway)
   - **Protocol:** HTTP
   - **Communication:** Client → Server, Synchronous Request/Response
   - **Description:** Allows the mobile application to access authentication, routes, and notifications services.

3. **Local invocation connector to Relational Database**
    - **Components:** runpath-mobile-frontend (Kotlin + Jetpack Compose) ↔ local-mobile-db (SQLite with Room)
    - **Protocol:** Local invocation (ORM / SQLite)
    - **Communication:** Local, synchronous
    - **Description:** Enables direct data persistence and retrieval within the mobile device. The `runpath-mobile-frontend` component accesses the local SQLite database through the Room ORM, without involving any network communication.

---

#### API Gateway Connectors

1. **HTTP/GraphQL Connector with Authentication**
   - **Components:** API Gateway (Express Gateway) ↔ runpath-login (FastAPI)
   - **Protocol:** HTTP/GraphQL
   - **Communication:** Client → Server, Synchronous Request/Response

2. **HTTP/REST Connector with Routes Service**
   - **Components:** API Gateway (Express Gateway) ↔ runpath-routes (Node.js)
   - **Protocol:** HTTP/REST
   - **Communication:** Bidirectional, Synchronous Request/Response

3. **HTTP/REST Connector with Distance Service**
   - **Components:** API Gateway (Express Gateway) ↔ runpath-distance (FastAPI)
   - **Protocol:** HTTP/REST
   - **Communication:** Client → Server, Synchronous Request/Response
  
4. **HTTP Connector with Notification Service**
   - **Components:** API Gateway (Express Gateway) ↔ runpath-notifications (SpringBoot)
   - **Protocol:** HTTP
   - **Communication:** Bidirectional, Synchronous Request/Response

---

#### Messaging Broker Connectors

1. **AMQP Connector with Notifications Service**
   - **Components:** runpath-broker (RabbitMQ) → runpath-notifications (Spring Boot)
   - **Protocol:** AMQP
   - **Communication:** Unidirectional, Asynchronous Communication (consume)

#### Client Connectors

##### Web Client Connectors

1. **HTTP Connector with the SSR Presentation Component**
   - **Components:** Web Browser ↔ runpath-frontend-ssr (Next.js)
   - **Protocol:** HTTP
   - **Communication:** Client→Server, Synchronous Request/Response

##### Mobile Client Connectors

1. **Local Invocation Connector with the Mobile Component**
   - **Components:** Mobile Client ↔ runpath-mobile (Kotlin + Jetpack Compose)
   - **Protocol:** Local Invocation
   - **Communication:** Local, In-process

### Architectural Style

#### Microservices Architecture

The system adopts a microservices architectural style, characterized by a distributed structure in which functionality is decomposed into small, independently deployable services.
Each microservice encapsulates a specific business capability — such as user authentication, route management, distance computation, or notification delivery — and interacts with others through well-defined communication interfaces (e.g., HTTP/REST, GraphQL).
Additionally, an API Gateway serves as the system’s orchestration and entry point, managing client requests, enforcing security policies, and coordinating service interactions to ensure consistency and scalability.

### Architectural Patterns

#### Broker Pattern

RunPath implements the Broker architectural pattern through the use of RabbitMQ.
This pattern supports asynchronous communication between services — in this case, runpath-routes publishes events (such as completed routes) that are consumed by runpath-notifications for email delivery.

The broker acts as an intermediary that decouples producers and consumers.

#### API Gateway Pattern

The system also applies the API Gateway pattern using Express Gateway.
This component serves as a single entry point for all external clients (web and mobile), handling authentication, routing, and request orchestration across multiple microservices.
The pattern simplifies client interactions by centralizing access and focuses on orchestrating and redirecting the overall system flow.

## Deployment Structure

### Deployment view

<p align="center"> <img src="./imgs/deployment_view.png" width="750"> </p>

### Description of Architectural Elements and Relations

#### Execution Environments

1. **Android Smartphone**
   - Hosts the `runpath-mobile-frontend` application, developed in Kotlin with Jetpack Compose.
   - Includes a local SQLite database (`local-mobile-db` via Room ORM) for caching routes and user progress offline.
   - Communicates securely with the API Gateway over HTTPS to access backend services.
   - Supports offline operations and periodic synchronization with central services.

2. **Server (routes_shared_network)**
   - Virtual host containing multiple Docker containers representing backend microservices and supporting components.
   - Containers communicate internally through a shared virtual network for isolation and controlled inter-service access.

   **Contained Elements:**
   - **osrm-colombia**  
     *Deployed Component:* `runpath-distance`  
     *Description:* Computes distances and geospatial metrics using OSRM, communicating with the Routes Service via the API Gateway.

   - **authentication-service**  
     *Deployed Component:* `runpath-login`  
     *Description:* Handles user authentication and session management; integrates with Firebase for identity services.

   - **routes-postgres**  
     *Deployed Component:* `geography-db`  
     *Description:* Stores route and geospatial data using PostgreSQL with PostGIS extensions.

   - **routes_app**  
     *Deployed Component:* `runpath-routes`  
     *Description:* Manages route creation, retrieval, updates, and publishing events to RabbitMQ.

   - **rabbit**  
     *Deployed Component:* `runpath-notifications-queue`  
     *Description:* Message broker enabling asynchronous, decoupled communication between Routes and Notifications services.

   - **notification-service**  
     *Deployed Component:* `runpath-notifications`  
     *Description:* Processes messages from RabbitMQ and sends user notifications via email.

   - **api-gateway**  
     *Deployed Component:* `API Gateway`  
     *Description:* Single entry point for frontends; handles routing, authentication, and request orchestration to backend services.

   - **runpath_frontend**  
     *Deployed Component:* `runpath-web-frontend-ssr`  
     *Description:* Web frontend (Next.js SSR) providing user interfaces for browsing and managing routes.

   - **loki, promtail, grafana**  
     *Deployed Component:* Observability stack  
     *Description:* Aggregates logs and metrics; provides monitoring dashboards and runtime diagnostics for all containers.

3. **Firebase Cloud Services**
   - Provides external cloud services:
     - `firebase-authentication`: user authentication and authorization.
     - `user-db`: NoSQL persistence for user profiles and credentials.
   - Communicates with the authentication-service via REST and SDK connectors.
   - Ensures secure and scalable user management outside the main server environment.

## Layered Structure

### Tier View

<img src="./imgs/logic layers.svg"/>

#### Elements description

##### `Tier 1 — Presentation`

- Frontend Web (NextJS SSR): web interface implementing Server-Side Rendering; consumes APIs via the API Gateway.

- Frontend Mobile (Kotlin): native Android app that provides the mobile UI; can operate online and keep a local DB (mobile-db) for sync/offline.

##### `Tier 2 — Orchestration`

- API Gateway (Express-gateway): unified entry point for frontends. Routes requests, applies policies (authentication/authorization), and forwards to microservices.

##### `Tier 3 — Logic`

- Authentication Service (Python - FastAPI): handles login, token issuance/validation, and user management.

- Routes Service (JS - NestJS): manages creation, querying, and filtering of routes (core domain). Produces messages to the Messenger Queue for async processing.

- Distances Service (OSRM-Backend - C++ service): specialized service for distance/route calculations, using geospatial data.

- Notification Service (Java - Spring): responsible for notifications (email). Consumes messages asynchronously from the messaging Queue.

##### `Tier 4 — Async Communication`

- Messenger Queue (RabbitMQ): message broker/queue for decoupling producers and consumers. Used for asynchronous tasks (e.g., sending notifications, batch processing, events).

##### `Tier 5 — Data (central persistence / storage)`

- geography-db (PostgreSQL): relational DB with geospatial capabilities (PostGIS implied) for map/route data.

- user-db (NoSQL): flexible-schema store for users/profiles/sessions with high availability.

- logs-db (Loki): logging store for observability/telemetry.

##### `Tier 6 — Mobile data (local mobile storage)`

- mobile-db (SQLite): on-device local DB for caching and offline operation/synchronization.

#### Relationships description

- `Presentation → Orchestration:` frontends call the API Gateway as the first access layer.

- `Orchestration → Logic:` the gateway routes requests to the appropriate microservices.

- `Logic → Data:` microservices access their data stores (geography-db, user-db, logs-db).

- `Logic → Async (RabbitMQ):` services publish to and/or consume from queues for asynchronous work (e.g., Routes Service publishes “route finished” events; Notification Service consumes and sends notifications).

- `Presentation (Mobile) → Mobile data (SQLite):` the mobile app uses its local DB to store data for offline access and sync.


#### Description of architectural patterns used

##### `N-tier Architecture`

Clear separation into Presentation, Orchestration, Logic, Data and an asynchronous communication layer. Helps responsibility separation, independent deployment and scaling.

##### `Local Cache + Sync`

Mobile local DB (SQLite) suggests an offline/sync pattern: the app functions with local data and synchronizes with the backend when connectivity is available.

##### `Centralized Logging / Observability`

logs-db (Loki) indicates centralized log collection for monitoring, tracing and diagnostics.

### Layered View

<img src="./imgs/layer view.drawio.svg"/>

#### Elements description

#### Frontend Layers

##### `Frontend Web (Next.js SSR)`

*Revisar las capas como estan definidas actualmente*

##### `Frontend Mobile (Kotlin)`

*Revisar las capas como estan definidas actualmente*

#### Orchestration Layers

##### `API Gateway (Express-Gateway)`
- **Layer 1: Presentation Layer:** Acts as the **public entry point**; defines external API endpoints, handles initial connections, and formats client responses.
- **Layer 2: Proxy Layer:** Performs **dynamic routing** of requests to the correct backend services and handles tasks like load balancing and basic request transformation.
- **Layer 3: Middleware Layer:** Enforces **cross-cutting concerns** such as authentication, authorization checks, API rate limiting, and centralized logging.
- **Layer 4: Service Integration Layer:** Manages **communication** with the backend microservices, handles protocol translation, service composition (orchestration), and error centralization.

#### Backend Layers

##### `Authentication Service (Python - FastAPI)`

- **Interface Layer:** Exposes REST APIs for user login, token validation, and management.  
- **Adapters Layer:** Converts external requests/responses into domain-friendly formats; interfaces with databases and external systems.  
- **Application Layer:** Coordinates user-related use cases such as login, registration, and token refresh.  
- **Domain Layer:** Contains the business logic for authentication and identity validation.  
- **Infrastructure Layer:** Manages repositories, persistence mechanisms, and security utilities (e.g., JWT).

##### `Routes Service (NestJS)`

- **Presentation Layer:** Provides REST endpoints and maps incoming requests to application use cases.  
- **Application Layer:** Implements the logic for route creation, querying, and filtering.  
- **Domain Layer:** Defines entities (Route, Segment, etc.) and business rules for route computation.  
- **Infrastructure Layer:** Handles data persistence and integration with RabbitMQ for asynchronous messaging.

##### `Distances Service (C++)`

- **API Layer:** Exposes routing and distance calculation endpoints to other services.  
- **Engine Layer:** Executes optimized routing algorithms (Dijkstra, A*, CH).  
- **Data Processing Layer:** Preprocesses and transforms map data for performance.  
- **Storage Layer:** Manages access to routing graph data and precomputed results.

##### `Notification Service (Java - Spring)`

- **Presentation Layer:** Defines endpoints and queue consumers for receiving notification events.  
- **Application Layer:** Coordinates notification delivery workflows.  
- **Messaging Layer:** Manages communication with RabbitMQ, retries, and message routing.  
- **Business Layer:** Defines templates, prioritization logic, and delivery policies.

#### Description of architectural patterns used

#### `Layered Architecture`

All services follow a layered design principle separating **presentation**, **application**, **domain**, and **infrastructure** concerns.  
This promotes modularity, independent testing, and clear boundaries between logic and technology.

#### `Hexagonal Architecture (Ports and Adapters)`

Used by the **Authentication Service**, this pattern isolates core business logic from external dependencies.  
It defines “ports” (interfaces) for core logic and “adapters” for connecting to frameworks, APIs, or databases.

#### `Clean Architecture`

Adopted by the **Routes Service**, ensuring a strict dependency rule — outer layers depend on inner layers, but not vice versa.  
It facilitates testability and maintainability in complex domain logic.

#### `MVVM / Layered Presentation`

Used by **Mobile (Kotlin)** to enforce separation between UI, presentation logic, domain, and data access layers.  
This allows scalable and reactive UIs while keeping state management predictable.

## Decomposition Structure

The **Run Path System** is composed of three main modules operating in a modular and coordinated manner: **User Authentication**, **Routes**, and **Notifications**. Each module performs a distinct role within the platform.

### Decomposition View

![Decomposition-View](./imgs/decomposition-view.drawio.png)

### Modules and functionalities

#### User Authentication 
Manages **user identity**, **access**, and **session control**and interacts through internal APIs and events to maintain consistency and scalability. to ensure secure authentication across the platform.

##### User Management
Handles the user account lifecycle:
- **Create user:** registers new users in the system.  
- **Update user:** updates user profile information.  
- **Delete user:** permanently removes a user account.  
- **Change password:** allows users to update their password.  

##### Session Management
Controls login and session state:
- **User login:** authenticates credentials and generates an access token.  
- **Log out:** invalidates the active user session.  
- **Verify token:** validates the authenticity and expiration of the access token.  

#### Routes Service
Responsible for the **creation**, **management**, and **search** of running routes.

##### Routes Management
Provides core CRUD functionality:
- **Create route:** allows users to define and save new running routes.  
- **Update route:** edits existing route details.  
- **Delete route:** removes a route from the system.  

##### Routes Search
Enables discovery and exploration of routes:
- **Get routes:** retrieves a general list of available routes.  
- **Filter nearby routes:** searches for routes near a specific geographic location.  
- **Get route information:** provides detailed information about a selected route.  

#### Notifications Service
Handles **email communications** triggered by user activity or engagement needs.

##### Email Notifications
Manages message composition and delivery:
- **Notify route completed:** sends a congratulatory email when a user completes a route.  
- **Send engagement emails:** sends reactivation or motivational emails to inactive users.  

# Quality attributes

## Security

### Scenario #1

### Scenario #2

### Scenario #3

### Scenario #4

### Architectural tactics applied

### Architectural patterns applied

## Performance and Scalability

### Scenario #1

### Scenario #2

### Architectural tactics applied

### Architectural patterns applied

### Performance testing analysis and results

# Prototype

## Deployment instructions

This section describes the detailed steps to configure and run the RunPath project locally using Docker containers.

### Prerequisites

Make sure you have installed:

- [Git](https://git-scm.com/downloads)
- [Docker](https://docs.docker.com/get-started/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)

### Create the Shared Docker Network

Before starting any service, create the Docker network that will allow communication between containers:

```bash
docker network create routes_shared_network
```

> *⚠️ Important:* This network is required for all services to communicate with each other. It must be created before starting any container.

---

## 1. Clone the Repositories

Clone all the necessary repositories for the system:

### Distance Calculation Service

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/distance-repository.git
```

### Route Management Service

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/route-service.git
```

### Authentication Service

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/authentication-service.git
```

### Web Frontend

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/frontend-ssr.git
```

### Notification Service

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/notification-service.git
```

### Logs Service

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/logs-service.git
```

### Mobile Frontend

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/front-mobile
```

### API Gateway

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/runpath-api-gateway.git
```

---

## 2. API Gateway Configuration

### URL available after deployment

*Base API:*

- http://localhost:8888

*APIs:*

- /authApi/
- /distanceApi/
- /routesApi/
- /notificationApi/

---

## 3. Authentication Service Configuration

### Firebase Configuration

1. Create a project in [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication and Firestore Database
3. Generate a service key and download the JSON file

### Environment Variables

Go to the repository directory:

```bash
cd route-service
```

Create the environment variable file `.env`:
```bash
# Linux environment
touch .env
```

Set the environment variables in `.env`:
```env
FIREBASE_CREDENTIALS_JSON='{"type": "service_account", ...}'
API_KEY='your_firebase_api_key'
```

### URLs available after deployment

- *API:* http://localhost:8888/authApi/

- *GraphQL Playground:* http://localhost:8888/authApi/graphql

---

## 4. Notification Service Configuration

To access the notification API, make sure to create a `.env` file related to the Google notification API containing the following variables:

```
- SPRING_MAIL_USERNAME
- SPRING_MAIL_PASSWORD
```

This exposes the following topic for the notification API:

- *QUEUE_TOPIC* : notification-queue

---

## 5. Distance Calculation Service Configuration

### URL available after deployment

- *API:* http://localhost:8888/distanceApi/

---

## 6. Route Management Service Configuration

Go to the repository directory:

```bash
cd route-service
```

### Environment Variables

1. Copy the example file:

```bash
# Linux environment
cp env.example .env.development
```

2. Configure the main variables:

```env
# Database Configuration for Development
DB_HOST=postgres
DB_PORT=5432
DB_USER=routes_user
DB_PASSWORD=routes_password
DB_NAME=routes_db

# Application Configuration
PORT=3000
NODE_ENV=development
AUTH_SERVICE_JWT_SECRET = SECRET_KEY
CALCULATION_SERVICE_URL = http://osrm-colombia:5000
AUTH_SERVICE_URL = http://authentication-service:8000/graphql

# RabbitMQ Configuration
RABBITMQ_URL=amqp://guest:guest@rabbit:5672

# Exchange Configuration (must match with Spring)
RABBITMQ_EXCHANGE=notification-exchange

# Exchange Type (topic, direct)
RABBITMQ_EXCHANGE_TYPE=direct

# Routing Key (must match with Spring)
RABBITMQ_ROUTING_KEY=notification-routing-key

# Reconnection Configuration
RABBITMQ_MAX_RECONNECT_ATTEMPTS=5
RABBITMQ_RECONNECT_DELAY=5000
```

### URLs available after deployment

- *API:* http://localhost:8888/routesApi/
- *Swagger Docs:* http://localhost:8888/routesApi/api/docs
- *Adminer (Admin DB):* http://localhost:8080

### Test Data

When the container is launched for the first time, **8 predefined routes** in Bogotá are automatically loaded to test the functionalities.

---

## 7. Web Frontend Configuration

### Environment Variables

Go to the directory:

```bash
cd frontend-ssr
```

Create the environment variable file `.env`:

```bash
# Linux environment
touch .env
```

Set the environment variables in `.env`:

```env
API_GATEWAY=http://api-gateway:8888
AUTH_SERVICE=authApi/graphql
DISTANCE_SERVICE=distanceApi/
ROUTES_SERVICE=routesApi/
PORT=3001
NEXT_PUBLIC_MAPBOX_TOKEN=your_mapbox_token
```

### URL available:

- *API:* http://localhost:3001

---

## 8. Mobile Frontend Configuration and Deployment

### Prerequisites

Make sure you have installed:

- [Android Studio](https://developer.android.com/studio)  
- A physical device or Android emulator  
- Active internet connection  

---

### Backend Configuration

For the mobile app to communicate with the local backend, expose the API Gateway using **ngrok**:

```bash
ngrok http 8888
```

Copy the URL generated by ngrok (for example: `https://abcd1234.ngrok-free.app`)  
and update it in the mobile app configuration file (utils):

```env
API_BASE_URL=https://abcd1234.ngrok-free.app
```

---

### Deployment

1. Open the **front-mobile** project in Android Studio.  
2. Connect a device or start an emulator.  Optional: Generate an .apk
3. Run the application using the **Run ▶️** button.  

---

### URL available after deployment

- *Mobile app running:* on connected Android device or emulator.

---

## 9. Logs Service Configuration

### URL available:

- *Grafana:* http://localhost:3000
- *Loki:* http://localhost:3100
- *Promptail:* http://localhost:9080

## 10. Recommended Deployment Order

For a successful deployment, follow this order:

1. *API Gateway Service*
2. *Authentication Service*
3. *Notification Service*
4. *Distance Calculation Service*
5. *Route Management Service*
6. *Web Frontend*
7. *Mobile Frontend*
8. *Logs Service*

### Full Deployment

From the root directory where the repositories were cloned, run the following commands in order:

```bash
# 1. API Gateway
cd runpath-api-gateway && docker compose up --build -d
# 2. Authentication Service
cd ../authentication-service && docker compose up --build -d
# 3. Notification Service
cd ../notifications-service && docker compose up --build -d
# 4. Distance Service
cd ../distance-repository && docker compose up --build -d
# 5. Route Service
cd ../route-service && npm run docker:dev
# 6. Web Frontend
cd ../frontend-ssr && docker compose up --build -d
# 7. Logs Service
cd ../logs-service && docker compose up --build -d
```

---

## 11. Deployment Verification

Once all services are running, verify that they are working correctly.

### Verification Commands

```bash
# Check container status
docker ps
```

### Check logs of a specific service
```bash
docker-compose logs -f [service_name]
```

