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
<img src="./imgs/cc_view_prototype3.png">
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

#### `runpath-notifications-queue`
- **Technology:** RabbitMQ
- **Description:** Messaging middleware that acts as an asynchronous intermediary between `runpath-routes` and `runpath-notifications`. It receives route completion events and delivers them for subsequent processing and user notification.

---

#### `API Gateway`
- **Technology:** Express Gateway
- **Description:** Internal gateway that receives requests from the mobile reverse proxy and the web frontend. It is responsible for orchestrating requests to the internal microservices, handling authentication and authorization.

---

#### `mobile-reverse-proxy`
- **Technology:** Nginx
- **Description:** Responsible for exposing a public endpoint for the mobile interface component. It masks direct access to the API Gateway and keeps backend services hidden from mobile users, controlling and redirecting traffic from the mobile client to the API Gateway.

---

#### `load-balancer-web-proxy-waf`
- **Technology:** nginx
- **Description:** Acts as a reverse proxy and Web Application Firewall (WAF). It exposes a public endpoint for web access, masks the location and address of the web frontend, API Gateway, and backend services from web users, and provides a boundary for incoming requests to mitigate potential DoS attacks.

---

#### `load-balance-auth`
- **Technology**: nginx
- **Description**: Acts as a load balancer for the authentication services that are replicated to ensure traffic distribution among the instances.

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
| `runpath-notifications-queue` | RabbitMQ | Asynchronous message queue between routes and notifications. | Receives events from `runpath-routes` and distributes them to `runpath-notifications`. |
| `API Gateway` | Express Gateway | Backend entry point; manages authentication and routes requests. | Connects mobile reverse proxy and web frontend with all backend microservices. |
| `mobile-reverse-proxy` | Nginx | Public entry point for mobile users. Masks the API Gateway to mobile users. | Redirects the request from mobile frontend to the API Gateway. |
| `load-balancer-web-proxy-waf` | Nginx | Public entry point for web users. Masks the web frontend and limits incoming requests. | Redirects the requests from web brower to web frontend and stops potential DoS attacks. |
| `load-balance-auth` | Nginx | Distribute the authentication requests between the authentication-containers | Redirects the requests from API Gateway to the authentication service |

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
   - **Components:** runpath-routes (Node.js) → runpath-notifications-queue (RabbitMQ)
   - **Protocol:** AMQP
   - **Communication:** Unidirectional, Asynchronous Communication (publish)

---

#### Notifications Service Connectors

1. **AMQP Connector with Messaging Broker**
   - **Components:** runpath-notifications (SpringBoot) → runpath-notifications-queue (RabbitMQ)
   - **Protocol:** AMQP
   - **Communication:** Unidirectional, Asynchronous Communication (consume)

---

#### Presentation Service Connectors (Frontend and Mobile)

1. **HTTP Connector with API Gateway**
   - **Components:** runpath-frontend (Next.js) ↔ API Gateway (Express Gateway)
   - **Protocol:** HTTP
   - **Communication:** Client → Server, Synchronous Request/Response
   - **Description:** Allows the web interface to interact with the system's microservices through the gateway.

2. **HTTP Connector with Reverse Proxy and Waf**
   - **Components:** runpath-frontend (Next.js) ↔ load-balancer-web-proxy-waf (Nginx)
   - **Protocol:** HTTP
   - **Communication:** Client → Server, Synchronous Request/Response
   - **Description:** Enables communication with the load-balancer-web-proxy-waf component, acting as an intermediary between web frontend and web client.

3. **HTTP Connector with Reverse Proxy (Mobile)**
   - **Components:** runpath-mobile (Kotlin) ↔ mobile-reverse-proxy (Nginx)
   - **Protocol:** HTTP
   - **Communication:** Client → Server, Synchronous Request/Response
   - **Description:** Allows the mobile application to communicate with the reverse proxy, intermediary between mobile frontend and api gateway.

4. **Local invocation connector to Relational Database**
    - **Components:** runpath-mobile-frontend (Kotlin + Jetpack Compose) ↔ local-mobile-db (SQLite with Room)
    - **Protocol:** Local invocation (ORM / SQLite)
    - **Communication:** Local, synchronous
    - **Description:** Enables direct data persistence and retrieval within the mobile device. The `runpath-mobile-frontend` component accesses the local SQLite database through the Room ORM, without involving any network communication.

---

#### API Gateway Connectors

1. **HTTP/GraphQL Connector with Load Balancer**
   - **Components:** API Gateway (Express Gateway) ↔ load-balance-auth (Nginx)
   - **Protocol:** HTTP
   - **Communication:** Bidirectional
  
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

#### Security componentes connectors

1. **HTTP Connector with web frontend**
   - **Components:** load-balancer-web-proxy-waf (Nginx) ↔ runpath-frontend (Next.js)
   - **Protocol:** HTTP
   - **Communication:** Bidirectional, Synchronous Request/Response

2. **HTTP Connector with web client**
   - **Components:** load-balancer-web-proxy-waf (Nginx) ↔ web client
   - **Protocol:** HTTP
   - **Communication:** Bidirectional, Synchronous Request/Response

3. **HTTP Connector with mobile frontend**
   - **Components:** mobile-reverse-proxy (Nginx) ↔ runpath-mobile-frontend (Kotlin + Jetpack Compose)
   - **Protocol:** HTTP
   - **Communication:** Bidirectional, Synchronous Request/Response

4. **HTTP Connector with api gateway**
   - **Components:** mobile-reverse-proxy (Nginx) ↔ API Gateway (Express Gateway)
   - **Protocol:** HTTP
   - **Communication:** Bidirectional, Synchronous Request/Response

---

#### Messaging Broker Connectors

1. **AMQP Connector with Notifications Service**
   - **Components:** runpath-broker (RabbitMQ) → runpath-notifications (Spring Boot)
   - **Protocol:** AMQP
   - **Communication:** Unidirectional, Asynchronous Communication (consume)

2. **AMQP Connector with Routes Service**
   - **Components:** runpath-routes (Node.js) → runpath-notifications-queue (RabbitMQ)
   - **Protocol:** AMQP
   - **Communication:** Unidirectional, Asynchronous Communication (publish)
  
---

#### Performance components connectors

1. **HTTP/GraphQL Connector with Authentication**
   - **Components:** load-balance-auth (Nginx) ↔ runpath-login (FastAPI)
   - **Protocol:** HTTP/GraphQL
   - **Communication:** Bidirectional

---

#### Client Connectors

##### Web Client Connectors

1. **HTTP Connector with the SSR Presentation Component**
   - **Components:** Web Browser ↔ load-balancer-web-proxy-waf (Nginx)
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

The system applies the API Gateway pattern using Express Gateway.
This component serves as a single entry point for all external clients (web and mobile), handling authentication, routing, and request orchestration across multiple microservices.
The pattern simplifies client interactions by centralizing access and focuses on orchestrating and redirecting the overall system flow.

#### Secure Channel Pattern

The RunPath System applies the Secure Channel Pattern.
This is evidenced by the connector provided for the web frontend, ensuring that all messages are exchanged through the HTTPS protocol, which encrypts and validates all requests and responses.
The pattern protects user credentials and sensitive information from potential attackers eavesdropping on the communication channel.

#### Reverse Proxy Pattern

The RunPath System applies the Reverse Proxy Pattern.
In the system, two reverse proxies are implemented for the public endpoints (one for the web client and one for the mobile client). These proxies mediate communication between the clients and the system in a secure manner, redirecting requests to their corresponding components and masking all internal infrastructure, including the API Gateway.
The pattern protects the system from attempts to scan or attack internal services.

#### Load Balancer Pattern

The RunPath System applies the Load Balancer Pattern.
In the system, there are two load balancers for the following services: Authentication and frontend-ssr. They are in charge of handles messages from various clients in order to distributed them among the computations available for each service.

#### WAF Pattern
The RunPath System applies the Web Application Firewall (WAF) Pattern.
The system integrates a WAF within the reverse proxy at the web client entry point, establishing a boundary on incoming requests from the same IP address within a given time interval, and displaying a locked window with a warning when the rule is triggered.
The pattern protects the web frontend component from potential Denial of Service (DoS) attacks.

## Deployment Structure

### Deployment view

<p align="center"> <img src="./imgs/deploy_view_prototype3.png" width="750"> </p>

### Description of Architectural Elements and Relations

#### Execution Environments

1. **Android Smartphone**
   - Hosts the `runpath-mobile-frontend` application, developed in Kotlin with Jetpack Compose.
   - Includes a local SQLite database (`local-mobile-db` via Room ORM) for caching routes and user progress offline.
   - Communicates securely with the API Gateway over HTTPS to access backend services.
   - Supports offline operations and periodic synchronization with central services.

2. **Server**
   - Host containing multiple Docker containers representing backend microservices and supporting components.
   - Containers communicate internally through a shared virtual network for isolation and controlled inter-service access.

   **Contained Elements:**
   - **osrm-colombia**  
     *Deployed Component:* `runpath-distance`  
     *Description:* Computes distances and geospatial metrics using OSRM, communicating with the Routes Service via the API Gateway.

   - **authentication-service** 
     *Deployed Component:* `runpath-login`  
     *Description:* Handles user authentication and session management; integrates with Firebase for identity services.

   - **authentication-service-1** 
     *Deployed Component:* `runpath-login`  
     *Description:* Handles user authentication and session management; integrates with Firebase for identity services.

   - **authentication-service-2** 
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

   - **frontend-ssr-1**  
     *Deployed Component:* `runpath-web-frontend-ssr`  
     *Description:* Web frontend (Next.js SSR) providing user interfaces for browsing and managing routes.

   - **frontend-ssr-2**  
     *Deployed Component:* `runpath-web-frontend-ssr`  
     *Description:* Web frontend (Next.js SSR) providing user interfaces for browsing and managing routes.
   
   - **mobile_nginx**  
     *Deployed Component:* `mobile-reverse-proxy`  
     *Description:* Mobile reverse proxy (Nginx), intermediary between mobile frontend component and API Gateway.
   
   - **reverse-proxy**  
     *Deployed Component:* `load-balancer-web-proxy-waf`  
     *Description:* Web reverse proxy and waf (Nginx), intermediary between web frontend component and web client.

   - **loki, promtail, grafana**  
     *Deployed Component:* Observability stack  
     *Description:* Aggregates logs and metrics; provides monitoring dashboards and runtime diagnostics for all containers.

   - **load-balance-auth**
     *Deployed Component:* `load-balance-auth`
     *Description:* Distributed traffic from authentication requests between the computations available for the service.
   
   - **ngin-tls-gateway**  
     *Deployed Component:* TLS stack  
     *Description:* Provides the TLS certificates for the HTTPS connector.

3. **Firebase Cloud Services**
   - Provides external cloud services:
     - `firebase-authentication`: user authentication and authorization.
     - `user-db`: NoSQL persistence for user profiles and credentials.
   - Communicates with the authentication-service via REST and SDK connectors.
   - Ensures secure and scalable user management outside the main server environment.

#### Network Schema

1. **db_net (172.30.0.0/16):** Private network dedicated to data management. Contains data components and services that exchange and manage information.
2. **backend_net (172.28.0.0/16):** Private network dedicated to handling service requests. Contains backend services and the API Gateway to enable the exchange of service requests and responses.
3. **orchestration_net (172.29.0.0/16):** Private network dedicated to managing the redirection of requests between entry points and the API Gateway. Contains the web frontend, API Gateway, and mobile reverse proxy.
4. **frontend_net (172.27.0.0/16):** Private network dedicated to enabling the exchange of requests between the web frontend component and the web reverse proxy.
6. **public_net (172.26.0.0/16):** Public network that contains the reverse proxies, allowing public access only to these components.


## Layered Structure

### Tier View

<img src="./imgs/tier_view_prototype3.drawio (2).png"/>

#### Elements description

##### `Tier 0 — Security`

-   **`web-proxy-waf (Nginx)`**: Acts as a reverse proxy and Web Application Firewall (WAF) for the web client. It exposes the public endpoint, masks the web frontend, and mitigates attacks (e.g., DoS).

##### `Tier 1 — Presentation`

-   `Frontend Web (NextJS SSR)`: web interface implementing Server-Side Rendering; consumes APIs via the API Gateway.
-   `Frontend Mobile (Kotlin)`: native Android app that provides the mobile UI; can operate online and keep a local DB (mobile-db) for sync/offline.

##### `Tier 2 — Edge`

-   **`mobile-reverse-proxy (Nginx)`**: Exposes a public endpoint for the mobile interface. It masks direct access to the API Gateway and redirects traffic from the mobile client.

##### `Tier 3 — Orchestration`

-   `API Gateway (Express-gateway)`: unified entry point for frontends. Routes requests, applies policies (authentication/authorization), and forwards to microservices.

##### `**Tier 4 — Load Balancing**`

-   **`Load Balancer (Nginx)`: An internal Nginx component that acts as an intermediary to distribute incoming requests to the `Authentication Service`, enhancing its scalability and resilience.**

##### `**Tier 5 — Logic**`

-   **`Tier 5.1: Logic`**
    -   `Authentication Service (Python - FastAPI)`: handles login, token issuance/validation, and user management.
-   **`Tier 5.2: Logic`**
    -   `Routes Service (JS - NestJS)`: manages creation, querying, and filtering of routes (core domain). Produces messages to the Messenger Queue for async processing.
    -   `Distances Service (Python - FastAPI)`: Service responsible for calculating distances between geographical points and analyzing route-related metrics.
    -   `Notification Service (Java - Spring)`: responsible for notifications (email). Consumes messages asynchronously from the messaging Queue.

##### `**Tier 6 — Async Communication**`

-   `Messenger Queue (RabbitMQ)`: message broker/queue for decoupling producers and consumers. Used for asynchronous tasks (e.g., sending notifications, batch processing, events).

##### `**Tier 7 — Data (central persistence / storage)**`

-   `geography-db (PostgreSQL)`: relational DB with geospatial capabilities (PostGIS implied) for map/route data.
-   `user-db (NoSQL)`: flexible-schema store for users/profiles/sessions, associated with the Firebase Authentication service.
-   `logs-db (Loki)`: logging store for observability/telemetry.

##### `**Tier 8 — Mobile data (local mobile storage)**`

-   `mobile-db (SQLite)`: on-device local DB for caching and offline operation/synchronization.

#### Relationships description

-   **`Web Flow:` `Tier 0 (Security)` receives requests and serves/protects `Tier 1 (Frontend Web)`. `Tier 1 (Frontend Web)` in turn consumes data from `Tier 3 (Orchestration)`.**
-   **`Mobile Flow:` `Tier 1 (Frontend Mobile)` communicates with `Tier 2 (Edge)`. This proxy securely forwards requests to `Tier 3 (Orchestration)`.**
-   **`Backend Logic Flow:` `Tier 3 (Orchestration)` routes requests directly to the services in `Tier 5.2 (Logic)`.**
-   **`Authentication Flow:` For authentication, `Tier 3 (Orchestration)` sends requests to `Tier 4 (Load Balancer)`, which then distributes them to `Tier 5.1 (Logic)`.**
-   **`Data Flow:` Services in both `Tier 5.1` and `Tier 5.2` access their required data stores in `Tier 7 (Data)`.**
-   **`Async Flow:` `Tier 5.2 (Logic)` services publish and/or consume messages from `Tier 6 (Async Communication)`.**
-   **`Mobile Data Flow:` `Tier 1 (Frontend Mobile)` uses its local DB in `Tier 8 (Mobile data)`.**

#### Description of architectural patterns used

##### `N-tier Architecture`

Clear separation into **Security, Presentation, Edge, Orchestration, Load Balancing, Logic, Data**, and **Async Communication** layers. Helps responsibility separation, independent deployment and scaling.

##### **`Load Balancing Pattern`**

**Implemented in `Tier 4` to distribute requests to the `Authentication Service`, improving its scalability and resilience.**

##### `Reverse Proxy Pattern`

Implemented in `Tier 0` and `Tier 2` to securely mediate communication between clients and the system, redirecting requests and masking the internal infrastructure.

##### `WAF Pattern`

Applied at the `web-proxy-waf` (Tier 0) to establish a boundary on incoming requests and protect the web frontend from common attacks like DoS.

##### `Local Cache + Sync`

Mobile local DB (SQLite) suggests an offline/sync pattern: the app functions with local data and synchronizes with the backend when connectivity is available.

##### `Centralized Logging / Observability`

logs-db (Loki) indicates centralized log collection for monitoring, tracing and diagnostics.

---

### Layered View

<img src="./imgs/layers_view_prototype3.drawio (2).png"/>

#### Elements description

#### Frontend Layers

##### `Frontend Web (Next.js SSR)`

-   **Layer 1: View Layer (Presentation):** Renders the final UI (HTML/CSS) presented to the user, composed of various components.
-   **Layer 2: Component (UI Logic):** Contains the reusable React components, managing their individual state and handling user interactions (event handlers).
-   **Layer 3: Business Logic:** Encapsulates client-side business rules and application state (e.g., user session, global state) that spans multiple components.
-   **Layer 4: Data Access:** Manages all communication with the API Gateway, handling data fetching (fetching/sending data) and state synchronization.

##### `Frontend Mobile (Kotlin)`

-   **Layer 1: View Layer (Presentation):** The UI screens (e.g., Jetpack Compose Composables or Android Views) responsible for displaying data and capturing user input.
-   **Layer 2: Presentation logic (View Model):** The ViewModel layer. It holds UI-related state, prepares data for the View, and handles presentation logic, surviving configuration changes.
-   **Layer 3: Domain Layer:** Contains the core business logic, use cases (interactors), and domain models, completely independent of the UI.
-   **Layer 4: Data Access:** The repository layer. It abstracts the data sources, managing whether to fetch data from the local `mobile-db` (SQLite) or the remote API.

#### **`Tier 0: Security Layer`**

##### **`load-balancer-web-proxy-waf (Nginx)`**

-   **Layer 1: Reverse Proxy:** Forwards HTTP/HTTPS requests to the `Frontend Web` component.
-   **Layer 2: WAF Ruleset:** Applies firewall rules (e.g., rate limiting) to filter malicious traffic.
-   **Layer 3: Caching Layer:** Caches static assets to improve performance.

#### **`Tier 2: Edge Layer`**

##### **`mobile-reverse-proxy (Nginx)`**

-   **`Layer 1: Configuration Layer`**: Contains Nginx configuration files that define routing rules, security headers, and proxy settings for all incoming mobile traffic.

#### **`Tier 3: Orchestration Layer`**

##### `API Gateway (Express-Gateway)`

-   **Layer 1: Presentation Layer:** Acts as the **public entry point**; defines external API endpoints, handles initial connections, and formats client responses.
-   **Layer 2: Proxy Layer:** Performs **dynamic routing** of requests to the correct backend services and handles tasks like load balancing and basic request transformation.
-   **Layer 3: Middleware Layer:** Enforces **cross-cutting concerns** such as authentication, authorization checks, API rate limiting, and centralized logging.
-   **Layer 4: Service Integration Layer:** Manages **communication** with the backend microservices, handles protocol translation, service composition (orchestration), and error centralization.

#### **`Tier 4: Load Balancing Layer`**

##### **`Load Balancer (Nginx)`**

-   **`Layer 1: Configuration Layer`**: Defines the upstream server pool (the `Authentication Service` instances) and the load balancing strategy (e.g., round-robin, least connections) to be used.

#### **`Tier 5: Logic Layers`**

##### **`Tier 5.1: Logic`**

##### `Authentication Service (Python - FastAPI)`

-   **Interface Layer:** Exposes REST APIs for user login, token validation, and management.
-   **Adapters Layer:** Converts external requests/responses into domain-friendly formats; interfaces with databases and external systems.
-   **Application Layer:** Coordinates user-related use cases such as login, registration, and token refresh.
-   **Domain Layer:** Contains the business logic for authentication and identity validation.
-   **Infrastructure Layer:** Manages repositories, persistence mechanisms, and security utilities (e.g., JWT).

##### **`Tier 5.2: Logic`**

##### `Routes Service (NestJS)`

-   **Presentation Layer:** Provides REST endpoints and maps incoming requests to application use cases.
-   **Application Layer:** Implements the logic for route creation, querying, and filtering.
-   **Domain Layer:** Defines entities (Route, Segment, etc.) and business rules for route computation.
-   **Infrastructure Layer:** Handles data persistence and integration with RabbitMQ for asynchronous messaging.

##### `Distances Service (Python - FastAPI)`

-   **Interface Layer:** Exposes REST/GraphQL endpoints for distance calculations and metrics.
-   **Adapters Layer:** Converts geospatial inputs (e.g., coordinates) into domain formats.
-   **Application Layer:** Orchestrates use cases, such as "Calculate Distance" or "Analyze Route Metric".
-   **Domain Layer:** Contains the pure business logic and algorithms for geospatial calculations.
-   **Infrastructure Layer:** Manages data access (e.g., to `geography-db`) or external map APIs.

##### `Notification Service (Java - Spring)`

-   **Presentation Layer:** Defines endpoints and queue consumers for receiving notification events.
-   **Application Layer:** Coordinates notification delivery workflows.
-   **Messaging Layer:** Manages communication with RabbitMQ, retries, and message routing.
-   **Business Layer:** Defines templates, prioritization logic, and delivery policies.

#### Description of architectural patterns used

#### `Layered Architecture`

All services follow a layered design principle separating **presentation**, **application**,**domain**, and **infrastructure** concerns.
This promotes modularity, independent testing, and clear boundaries between logic and technology.

#### `Hexagonal Architecture (Ports and Adapters)`

Used by the **`Authentication Service`** and **`Distances Service`**, this pattern isolates core business logic from external dependencies.
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

![Decomposition-View](./imgs/decomposition_view_prototype3.png)

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

### Scenario #1 - Unauthorized Interception and Network Link Compromise

* **Source:** Any malicious actor attempting to intercept or alter communications between the web client and the system.
* **Stimulus:** Attempts to perform a network sniffing or Man-in-the-Middle (MitM) while a user exchanges information with the web frontend.
* **Artifact:** Communication channel between the web client and the runpath-web-frontend component.
* **Enviroment:** Normal operation.
* **Response:** The system enforces encrypted communication using the HTTPS (TLS) protocol at the web frontend level. The TLS layer guarantees confidentiality, integrity, and authentication of all transmitted data.
* **Response measure:**
    * **Confidentiality:** The attacker is unable to read the plain-text content of the data (it remains encrypted).
    * **Integrity:** Any modification to the data by the attacker is detected by the client or server (due to the integrity check failing), and the tampered data is rejected.

<p align="center">
<img src="./imgs/scenario1_linkcompromise.png">
</p>

---

### Scenario #2 - Unauthorized Access to Private Components

* **Source:** Any external malicious actor or automated scanner operating from the public internet.
* **Stimulus:** Attempts to directly reach backend or orchestration services by bypassing the public interfaces of the system.
* **Artifact:** The Private/Critical Components.
* **Enviroment:** Normal operation with high volume of traffic requests.
* **Response:** Reverse proxies mediate all incoming HTTP requests directed to the system, exposing only approved endpoints and to forward requests exclusively to their mapped services.
* **Response measure:**
    * **Access Control:** All unauthorized attempts to access or bypass the proxy to reach a private component are blocked.
    * **Non-Repudiation (Server Anonymity):** Attackers cannot infer private IP addresses or service configurations behind the proxy, limiting reconnaissance opportunities.

<p align="center">
<img src="./imgs/scenario2_unauthorizedaccess.png">
</p>

---

### Scenario #3 - Public Exposure of Critical Components

* **Source:** An internal or external attacker who has already successfully gained initial access/a foothold on one part of the network.
* **Stimulus:** The attacker attempts lateral movement to reach internal assets, such as databases or sensitive backend services.
* **Artifact:** The Internal Network Segments (specifically, the target segment)
* **Enviroment:** Post-compromise of a low-value asset in a public segment.
* **Response:** The deployment enforces network segmentation through distinct subnets and routing domains. Only explicitly defined connections are permitted between subnets, preventing unsolicited or cross-segment traffic.
* **Response measure:** 
It is important to consider that we cannot ensure the following elements, however, the response helps with the mitigation of them.
   * **Containment:** The attacker's attempt to send packets to the sensitive private segment is rejected by the routing/switching infrastructure at the subnet boundary.
   * **Confidentiality/Integrity:** The high-value assets in the private subnet remain inaccessible and uncompromised, preventing widespread damage following a localized breach.

<p align="center">
<img src="./imgs/scenario3_publicexposure.png">
</p>

---

### Scenario #4 - Service Degradation or Denial Due to Excessive Traffic

* **Source:** An attacker or automated botnet attempting to degrade or halt application service availability.
* **Stimulus:** Submits an overwhelming volume of requests to the web frontend to exhaust its processing capacity.
* **Artifact:** The runpath-web-frontend component and its public endpoint.
* **Enviroment:** Normal operation, handling legitimate HTTP/S requests alongside a surge of malicious traffic.
* **Response:** The Web Application Firewall (WAF) analyzes the traffic flow for behavioral anomalies, such as request rates exceeding established thresholds from a single source or IP range. It then applies rate limiting and/or connection throttling to the abusive traffic pattern and drops the offending requests.
* **Response measure:**
    * **Availability (Service Denial Prevention):** The WAF sustains the service's availability for legitimate users by shedding the malicious load.
    * **Throughput/Latency:** The rate of processing for legitimate requests is maintained above a critical threshold, and latency remains within acceptable bounds, despite the attack.

<p align="center">
<img src="./imgs/scenario4_servicedegradation.png">
</p>

### Architectural tactics applied

#### **1. Encrypt Data**

**Description:** This tactic aims to protect the confidentiality and integrity of data in transit through end-to-end encryption, entity authentication, and message integrity verification (e.g., TLS with certificates and MAC mechanisms).
**Application:** It is applied on the public channel between the web browser and the runpath-web-frontend component, ensuring that all HTTP requests are negotiated as HTTPS (TLS). Operational evidence includes valid digital certificates on the frontend and TLS negotiation on public ports.
**Associated Pattern:** Secure Channel Pattern.

#### **2. Limit Access**

**Description:** This tactic focuses on minimizing the attack surface and controlling access to internal resources through intermediaries and filtering policies, minimizing endpoint exposure, enforcing strict routing rules, hiding metadata, and blocking unauthorized traffic before it reaches internal services.
**Application:** It is implemented at public entry points (the reverse proxies serving the web and mobile frontends). These proxies enforce routing rules, ACLs, and filters that only allow explicitly authorized traffic toward mapped services, while hiding internal addresses and headers. It is also visible in inter-subnet access rules that restrict which entities can invoke services within backend_net and orchestration_net.
**Associated Pattern:** Reverse Proxy Pattern.

#### **3. Detect Service Denial**

**Description:** This tactic aims to detect and mitigate service degradation attempts by performing real-time traffic analysis (detecting bursts, suspicious IPs, and anomalous request patterns) and applying automated countermeasures such as rate limiting, connection throttling, temporary blocking, and challenge-response mechanisms. The goal is to preserve availability for legitimate users while filtering out malicious load.
**Application:** It is implemented in the WAF layer integrated into the inbound proxy for the web frontend (load-balancer-web-proxy-waf), where request-rate metrics and attack signatures are continuously monitored. Mitigation policies are executed at this layer before traffic reaches runpath-web-frontend.
**Associated Pattern:** Web Application Firewall (WAF) Pattern.

### Architectural patterns applied

#### **1. Secure Channel Pattern**

The RunPath System applies the Secure Channel Pattern.
This is evidenced by the connector provided for the web frontend, ensuring that all messages are exchanged through the HTTPS protocol, which encrypts and validates all requests and responses.
The pattern protects user credentials and sensitive information from potential attackers eavesdropping on the communication channel.

#### **2. Reverse Proxy Pattern**

he RunPath System applies the Reverse Proxy Pattern.
In the system, two reverse proxies are implemented for the public endpoints (one for the web client and one for the mobile client). These proxies mediate communication between the clients and the system in a secure manner, redirecting requests to their corresponding components and masking all internal infrastructure, including the API Gateway.
The pattern protects the system from attempts to scan or attack internal services.

#### **3. Network Segmentation Pattern**

The RunPath System applies the Network Segmentation Pattern.
Each system tier is isolated within a private network, allowing communication only between components in adjacent network layers. This prevents access to private components even if an attacker gains information about their locations.
The pattern prevents unauthorized entities from sending direct requests to backend components, protecting them from direct attacks.

#### **4. Web Application Firewall (WAF) Pattern**
The RunPath System applies the Web Application Firewall (WAF) Pattern.
The system integrates a WAF within the reverse proxy at the web client entry point, establishing a boundary on incoming requests from the same IP address within a given time interval, and displaying a locked window with a warning when the rule is triggered.
The pattern protects the web frontend component from potential Denial of Service (DoS) attacks.

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

