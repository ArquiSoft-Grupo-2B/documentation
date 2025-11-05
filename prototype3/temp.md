# **Frontend Presentation Tier**

This section describes the architectural patterns used in the **Frontend Tier** of the **Run Path System**, which includes both **Web** and **Mobile** clients.  
Each frontend follows a **Presentation Architecture** adapted to its framework and rendering model.

---

## **Frontend Web (Next.js SSR - Presentation Architecture)**

### **Pattern:** *Layered Presentation Architecture (MVVM-Influenced)*

The **Web Frontend** built with **Next.js (Server-Side Rendering)** follows a layered presentation pattern that separates rendering, component logic, and data access to improve maintainability and performance.

### **Layer Description**

| Layer | Description |
|-------|--------------|
| **Layer 1: View Layer (Presentation)** | Handles server-side and client-side rendering using Next.js pages and components. Manages user interaction and visual representation. |
| **Layer 2: Component Layer (UI Logic)** | Encapsulates the logic of reusable UI components (React components, hooks, and state handlers). Responsible for presentation behavior and component state. |
| **Layer 3: Business Logic** | Implements client-side rules and orchestrates communication with backend APIs. Handles input validation, transformations, and session management. |
| **Layer 4: Data Access** | Manages API calls to backend services (REST or GraphQL). Abstracts data fetching and state hydration during SSR and CSR phases. |

---

## **Frontend Mobile (Flutter - Presentation Architecture)**

### **Pattern:** *MVVM (Model-View-ViewModel) Architecture*

The **Mobile Frontend** built with **Flutter** follows the **MVVM** pattern, enabling a clear separation between the UI and its reactive logic through state management (e.g., Provider, Riverpod, or BLoC).

### **Layer Description**

| Layer | Description |
|-------|--------------|
| **Layer 1: View Layer (Presentation)** | Defines the UI widgets that render the interface. Listens to the ViewModel for state updates and displays corresponding changes. |
| **Layer 2: Presentation Logic (ViewModel)** | Contains state management and UI orchestration logic. Reacts to user actions and communicates with the domain layer. |
| **Layer 3: Domain Layer** | Encapsulates application-specific business rules and use cases. Translates app events into actions and responses for the ViewModel. |
| **Layer 4: Data Access** | Handles repositories, API clients, and local persistence (e.g., SQLite, SharedPreferences). Provides unified data access interfaces. |

---

## **Summary of Patterns by Frontend**

| Frontend | Technology | Pattern | Key Feature |
|-----------|-------------|----------|--------------|
| **Web** | Next.js (React + SSR) | **Layered Presentation Architecture** | Server-side rendering with clear UI and logic separation |
| **Mobile** | Flutter | **MVVM Architecture** | Reactive state-driven UI with separation of concerns |





# **Architectural Patterns Overview**

This section describes the architectural patterns applied to each microservice in the **Run Path System** logical tier.  
Each service follows a layered or hexagonal approach depending on its domain complexity, technology, and interaction with external components.

---

## **Authentication Service (Python)**

### **Pattern:** *Hexagonal Architecture (Ports and Adapters)*

The **Authentication Service** is structured following the **Hexagonal (Ports and Adapters)** pattern, emphasizing separation between the **core domain logic** and external dependencies.

### **Layer Description**

| Layer | Description |
|-------|--------------|
| **Layer 1: Interface Layer** | Entry point for user requests (e.g., REST APIs). Defines controllers that expose authentication functionalities. |
| **Layer 2: Adapters Layer** | Adapts incoming/outgoing data and orchestrates communication between the application core and external systems (e.g., databases, token services). |
| **Layer 3: Application Layer** | Coordinates use cases like user registration, login, and session validation. Contains service-level logic without business rules. |
| **Layer 4: Domain Layer** | Core business rules (entities, value objects, domain services). Completely independent of frameworks and infrastructure. |
| **Side Layer: Infrastructure Layer** | Implements repositories, database access, and security components (e.g., JWT, password hashing). Connected via adapters. |

---

## **Routes Service (NestJS)**

### **Pattern:** *Clean Architecture*

The **Routes Service** adopts a **Clean Architecture** approach, emphasizing strict dependency inversion and separation of concerns across four concentric layers.

### **Layer Description**

| Layer | Description |
|-------|--------------|
| **Layer 1: Presentation Layer** | Handles incoming HTTP requests via controllers. Maps them to application use cases. |
| **Layer 2: Application Layer** | Implements use cases related to route management (create, update, search). Coordinates domain and infrastructure components. |
| **Layer 3: Domain Layer** | Contains core entities (Route, Segment, UserRoute) and domain rules such as distance validation and route constraints. |
| **Layer 4: Infrastructure Layer** | Manages data persistence (ORM, database access) and external services like geolocation or route caching. |

---

## **Distances Service (OSRM Backend - C++ Service)**

### **Pattern:** *Layered (Engine-Centric Architecture)*

This service follows a **Layered (N-tier) architecture**, optimized for high-performance backend computation typical of **routing engines** such as OSRM.

### **Layer Description**

| Layer | Description |
|-------|--------------|
| **Layer 1: API Layer** | Exposes C++ endpoints (REST or binary protocols) to external consumers for route distance queries. |
| **Layer 2: Engine Layer** | Core computational logic. Executes routing algorithms (Dijkstra, A*, CH). |
| **Layer 3: Data Processing Layer** | Handles map data preprocessing, parsing, and transformation for efficient querying. |
| **Layer 4: Storage Layer** | Manages memory and disk-level access to precomputed routing data (graphs, indexes, coordinates). |

---

## **Notification Service (Java)**

### **Pattern:** *Layered (Domain-Driven Layered Architecture)*

The **Notification Service** follows a **Layered (DDD-inspired)** structure, focusing on clear segregation between presentation, message handling, and business logic.

### **Layer Description**

| Layer | Description |
|-------|--------------|
| **Layer 1: Presentation Layer** | Exposes APIs or message endpoints for publishing and receiving notifications. |
| **Layer 2: Application Layer** | Coordinates notification delivery use cases (email, SMS, push). Integrates with message brokers. |
| **Layer 3: Messaging Layer** | Manages asynchronous communication via message queues (e.g., Kafka, RabbitMQ). Handles retries and message delivery guarantees. |
| **Layer 4: Business Layer** | Encapsulates domain logic for notification templates, prioritization, and delivery rules. |

---

## **Summary of Patterns by Service**

| Service | Technology | Pattern | Key Feature |
|----------|-------------|----------|--------------|
| **Authentication Service** | Python | **Hexagonal Architecture** | High modularity and external system decoupling |
| **Routes Service** | NestJS | **Clean Architecture** | Strong domain separation and testability |
| **Distances Service** | C++ (OSRM) | **Layered Architecture** | Performance-focused computation and data flow |
| **Notification Service** | Java | **Layered (DDD-inspired)** | Message-driven coordination and delivery logic |


---

### Relations and Communication

- **Frontend Web ↔ API Gateway:** The web frontend (Next.js SSR) communicates with backend services through the API Gateway over HTTP/HTTPS.  
- **Frontend Mobile ↔ API Gateway:** The mobile app (Kotlin) communicates with backend services through the API Gateway over HTTP/HTTPS.  
- **Mobile ↔ Local Database:** The mobile app accesses its local SQLite database (`local-mobile-db`) for caching routes and offline operations.  
- **Backend Microservices ↔ API Gateway:** All backend microservices communicate with each other indirectly via the API Gateway; there are no direct service-to-service connections.  
- **Routes Service ↔ RabbitMQ:** Routes service publishes events to RabbitMQ for asynchronous processing.  
- **Notifications Service ↔ RabbitMQ:** Notifications service consumes events from RabbitMQ for asynchronous message handling.  
- **Routes Service ↔ PostgreSQL:** Routes service queries and updates geospatial route data in the PostgreSQL/PostGIS database.  
- **Authentication Service ↔ Firebase:** Authentication service integrates with Firebase for user identity, access control, and NoSQL profile persistence.  
- **Observability Stack (Loki, Promtail, Grafana):** Collects logs and metrics from all containers for monitoring, diagnostics, and operational visibility.  
- **Distance Service:** Provides route and distance calculations via the API Gateway; does not directly connect to a database.  

---