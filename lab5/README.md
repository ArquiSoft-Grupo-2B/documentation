<p align="center">
<img src="./img/UNAL.png" width="200">
</p>
<h2 align="center"><big>Laboratory 5</big></br>Security</br>Team 2B<br></br></h2>

# Team

- Samuel Josué Vargas Castro
- Daniel Felipe Soracipa
- Juan Esteban Cárdenas Huertas
- Juan David Ardila Diaz
- Martin Moreno Jara
- Juan José Medina Guerrero
- Sergio Enrique Vargas Pedraza

---

# Laboratory 5 - Security

## Network segmentation pattern

The Network Segmentation Pattern is an architectural tactic for Limit Access (a
form of Attack Resistance). It involves partitioning a network into distinct,
isolated logical subnets, specifically separating Public (Internet-facing, uses
public IPs) and Private (sensitive resources, uses private IPs) areas.

Its core purpose is to strictly control traffic flow between these segments and
prevent the lateral spread of a security compromise. By isolating critical
assets in the Private Subnet, the pattern minimizes their exposure to untrusted
networks like the Internet, ensuring only inspected and authorized traffic can
reach them.

### Quality scenario addressed

The Network Segmentation Pattern primarily addresses Confidentiality and
Integrity, and contributes significantly to Availability.

**Confidentiality**

It shields sensitive data and internal systems (located in the Private Subnet)
from unauthorized disclosure by blocking direct access from external or
less-trusted network segments.

**Integrity**

By controlling the traffic flow, it prevents unauthorized modification or
deletion of data by restricting what an attacker can do even if they compromise
a public-facing segment.

**Availability (Contribution)**

It limits the blast radius of an attack or failure. By containing a security
incident within a specific network segment, the pattern ensures that critical
services in other segments remain operational and available to users.

## Example implementation

### Components & Connectors (C&C) View

**Note:** The components-and-connectors view does not represent the implemented
pattern itself; it is presented solely to provide a complete understanding of
the components involved in the scenario and how they interact with each other.
Additionally, it gives context to the deployment view, where the implementation
of the pattern is actually evident.

<img src="./img/Lab5CandC.png" width="800">

### Deployment View

<img src="./img/Lab5Deploy.png" width="800">

### Description of the example scenario

This example implements a **microservices-based web application** that
demonstrates the Network Segmentation Pattern through a multi-tier architecture
handling user authentication and entry management. The system is designed to
protect sensitive data and prevent unauthorized access through strategic network
isolation.

#### System Components

The application consists of six containerized components organized across four
isolated network segments:

**Presentation Tier:**

- **Frontend Web Application** (React/Vite): A single-page application serving
  as the user interface, running on port 5173

**Gateway Tier:**

- **API Gateway** (NGINX): Acts as the reverse proxy and single entry point for
  all API requests, exposed on port 8080

**Application Tier:**

- **Users Service** (Flask/Python): Manages user authentication and profile
  data, internally accessible on port 5000
- **Entry Service** (Express/Node.js): Handles entry creation and retrieval
  operations, internally accessible on port 3000

**Data Tier:**

- **MongoDB**: NoSQL database storing user-related documents
- **PostgreSQL**: Relational database managing entry records

#### Security Scenario

**Threat Model:**

The system addresses the following security concerns:

1. **External Attack Vector**: An attacker attempting to exploit vulnerabilities
   in the frontend application to gain direct access to backend services or
   databases
2. **Lateral Movement**: A compromised backend service attempting to access
   other services or databases it shouldn't have permission to reach
3. **Data Exfiltration**: Unauthorized attempts to extract sensitive user data
   or entry information directly from the database layer
4. **Service Impersonation**: Malicious actors trying to bypass the API gateway
   to directly invoke backend APIs

**Security Requirements:**

The network segmentation pattern is applied to satisfy these security
requirements:

- **SR-1**: User credentials and sensitive data stored in databases must not be
  directly accessible from external networks or the frontend tier
- **SR-2**: Backend microservices must only be accessible through the authorized
  API gateway, never directly from clients
- **SR-3**: Database connections must be restricted exclusively to their
  respective backend services
- **SR-4**: A compromise in any single tier must not automatically grant access
  to other tiers
- **SR-5**: All inter-service communication must follow defined, auditable paths

**Segmentation Strategy:**

```yaml
services:
  frontend-web:
    build:
      context: ./frontend-web
      dockerfile: Dockerfile
    container_name: frontend-web
    ports:
      - '5173:5173'
    networks:
      - frontend-net
      - orchestration-net
    depends_on:
      - api-gateway
    restart: unless-stopped

  api-gateway:
    build:
      context: ./api-gateway
      dockerfile: Dockerfile
    container_name: api-gateway
    expose:
      - '8080'
    networks:
      - orchestration-net
      - backend-net
    depends_on:
      - users-service
      - entry-service
    restart: unless-stopped

  # FLASK
  users-service:
    build:
      context: ./users-service
      dockerfile: Dockerfile
    container_name: users-service
    expose:
      - '5000'
    networks:
      - backend-net
      - database-net
    depends_on:
      - mongodb
    restart: unless-stopped

  # EXPRESS
  entry-service:
    build:
      context: ./entry-service
      dockerfile: Dockerfile
    container_name: entry-service
    expose:
      - '3000'
    networks:
      - backend-net
      - database-net
    depends_on:
      - postgresdb
    restart: unless-stopped

  mongodb:
    image: mongo:latest
    container_name: mongodb
    expose:
      - '27017'
    volumes:
      - mongo-data:/data/db
    networks:
      - database-net
    restart: unless-stopped

  postgresdb:
    image: postgres:16
    container_name: postgresdb
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydatabase
    expose:
      - '5432'
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - database-net
    restart: unless-stopped

volumes:
  mongo-data:
  postgres-data:

networks:
  frontend-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/24

  orchestration-net:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.31.0.0/24

  backend-net:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.32.0.0/24

  database-net:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.34.0.0/24
```

#### Network Segmentation Architecture Explanation

This `docker-compose.yml` file implements a **multi-tier network segmentation
architecture** that isolates different layers of the application.

The architecture implements four network segments:

**1. Frontend Network (`frontend-net`) [Public segment]**

- **Subnet**: `172.30.0.0/24`
- **Connected Services**: `frontend-web`
- **Purpose**: Isolates the presentation layer, providing the only publicly
  accessible entry point to the application
- **Security Benefit**: External-facing components are separated from internal
  services, with no `internal: true` flag allowing controlled external access

**2. Orchestration Network (`orchestration-net`) [Private segment]**

- **Subnet**: `172.31.0.0/24`
- **Connected Services**: `frontend-web`, `api-gateway`
- **Purpose**: Facilitates communication between the frontend and API gateway
  while keeping this traffic isolated from backend services
- **Security Benefit**: The `internal: true` flag prevents external routing and
  internet access, ensuring orchestration traffic remains internal

**3. Backend Network (`backend-net`) [Private segment]**

- **Subnet**: `172.32.0.0/24`
- **Connected Services**: `api-gateway`, `users-service`, `entry-service`
- **Purpose**: Enables communication between the API gateway and backend
  microservices
- **Security Benefit**: The `internal: true` flag prevents external routing;
  backend services are not directly accessible from the frontend, and all
  traffic must pass through the gateway

**4. Database Network (`database-net`) [Private segment]**

- **Subnet**: `172.34.0.0/24`
- **Connected Services**: `users-service`, `entry-service`, `mongodb`,
  `postgresdb`
- **Purpose**: Isolated data persistence layer
- **Security Benefit**:
  - The `internal: true` flag prevents external routing and internet access
  - Databases are completely isolated from the frontend and only accessible by
    authorized backend services
  - No direct database access from outside the Docker network

**Attack Resistance:**

This segmentation strategy achieves the following security properties:

- **Controlled Entry Points**: The API gateway serves as a choke point where
  authentication, authorization, rate limiting, and request validation occur
  before reaching backend services
- **Privilege Isolation**: The frontend has zero knowledge of backend service
  endpoints or database connection strings
- **Blast Radius Containment**: If the frontend is compromised, the attacker
  gains no direct access to backend APIs or databases
- **Traffic Inspection**: All requests traverse defined network boundaries,
  enabling comprehensive logging, monitoring, and intrusion detection
- **Database Hiding**: With the `internal: true` flag on the database network,
  even if an attacker compromises a backend service, they cannot route database
  traffic outside the Docker environment

**Quality Attributes Achieved:**

- **Confidentiality**: Sensitive data remains protected through layered access
  controls
- **Integrity**: Unauthorized modification is prevented by restricting write
  access paths
- **Availability**: Service isolation ensures that a failure or attack in one
  segment doesn't cascade to others
- **Auditability**: Clear network boundaries enable comprehensive security
  logging and compliance reporting

### Steps to follow

**1. Retrieve the Software System**

Clone the application repository from the source repository using the
`git clone` command:

```bash
git clone https://github.com/ArquiSoft-Grupo-2B/network-segmentation-example.git
```

**2. Build and Launch Containers**

The docker-compose.yml file defines the services, networks, and volumes required
for the application. The `--build` flag ensures that all necessary service
images are built before the containers are launched.

```bash
docker compose up --build -d
```

**3. Verify Docker Network Creation**

List all networks managed by the Docker daemon to confirm the creation of the
custom network provisioned by Docker Compose:

```bash
docker network ls
```

At the very least, you should see four networks, beside the three default Docker
networks (bridge, host, and none):

_Example_

```
26546d47b752   bridge                   bridge    local
153139c313bc   host                     host      local
845a37fd2ed2   <backend-net>         bridge    local
8aa492fb381d   <database-net>        bridge    local
0bf713f93b8d   <frontend-net>        bridge    local
f47827b7f6d1   <orchestration-net>  bridge    local
611d60704b9f   none                     null      local
```

**4. Inspect Network Structure and Connected Containers**

Use the `docker network inspect <network>`command, referencing the specific
network identifier (ID or Name), to examine the configuration details, including
IP addressing, network scope, and, **most importantly**, the list of connected
containers within that isolated network segment.

```bash
docker network inspect <network_identifier>
```

- The `frontend-net` (subnet 172.30.0.0/24) should contain only the frontend
  container.
- The `orchestration-net` (subnet 172.31.0.0/24) should include the frontend and
  api-gateway containers.
- The `backend-net` (subnet 172.32.0.0/24) should contain the api-gateway,
  users-service, and entry-service containers.
- The `database-net` (subnet 172.34.0.0/24) should include the mongodb,
  postgresdb, users-service, and entry-service containers.

**5. Test connectivity between networks**

Validate inter-network communication by testing connectivity between containers
located in different network domains. This step confirms whether the implemented
network segmentation correctly isolates or allows communication across defined
boundaries.

**Execute Connectivity Tests Between Containers**

To ensure proper network segmentation and communication, execute the following
tests:

1. **Frontend Communication**

- Access the frontend container through:
  ```bash
  docker exec -it <frontend_container_name> sh
  ```
- From the frontend container, attempt to access the orchestration (api gateway)
  service:

  ```bash
  $ curl http://api-gateway:8080/api/users
  $ curl http://api-gateway:8080/api/entries
  ```

  The first command should return a list of users, and the second a list of
  entries. Both are accesible, as the frontend and api-gateway containers share
  the same network.

- Attempt to access the backend services directly from the frontend container:

  ```bash
  $ curl http://users-service:5000/
  $ curl http://entry-service:3000/
  ```

  Both commands should fail, indicating that the host could not be resolved, as
  they are not in the same network.

- Attempt to ping the database containers from the frontend container:
  ```bash
  $ ping mongodb
  $ ping postgresdb
  ```
  Both commands should fail, as the database containers are not reachable from
  the frontend network.

2. **Orchestration Communication**

- Access the orchestration container through:

  ```bash
  docker exec -it <orchestration_container_name> sh
  ```

- From the orchestration container, attempt to access the frontend service:

  ```bash
  $ curl http://frontend-web:5173/
  ```

  This command should return an successful HTML response, as both containers
  share the same network.

- From the orchestration container, attempt to access the backend services:

  ```bash
  $ curl http://users-service:5000/
  $ curl http://entry-service:3000/
  ```

  Both commands should return successful responses, as the orchestration and
  backend containers share the same network.

  The first command should return "Backend 1 - Users API", and the second
  "Backend 2 - Entries API".

- Attempt to access the database containers from the orchestration container:
  ```bash
   $ ping mongodb
   $ ping postgresdb
  ```
  Both commands should fail, as the database containers are not reachable from
  the orchestration network.

3. **Backend Communication**

- Access one of the backend containers (e.g., users service) through:

  ```bash
  docker exec -it <users_service_container_name> sh
  ```

- Attempt to access the orchestration service from the backend containers:

  ```bash
  $ curl http://api-gateway:8080/api/users
  $ curl http://api-gateway:8080/api/entries
  ```

  Both commands should return successful responses.

- Attempt to acces the other backend service from the backend container:

  ```bash
    $ curl http://entry-service:3000/
  ```

  This command should return a successful response.

- Attempt to access the database containers from the backend container:
  ```bash
   $ ping mongodb
   $ ping postgresdb
  ```
  Both commands should succeed, as the backend and database containers share the
  same network. These backend containers are the only ones that can access the
  database containers.

This tests confirm that the network segmentation is functioning as intended
according to the flow rules defined in the architecture.

## Project implementation

To implement this pattern in our project, we created four isolated subnets with specific
roles, each designed to enforce strict network segmentation and minimize the attack surface:

- **backend_net** (172.28.0.0/16): A private subnet that contains all backend services including microservices, message brokers, and monitoring tools. It also includes the API Gateway to orchestrate backend communication.

- **frontend_net** (172.27.0.0/16): A public subnet that hosts the frontend service, providing the only user-facing entry point to the system.

- **db_net** (172.30.0.0/16): A dedicated database subnet that isolates all data persistence layers. It allows the `routes_app` service to connect exclusively to its PostgreSQL database, ensuring that no unauthorized service can access the data tier.

- **orchestration_net** (172.29.0.0/16): A private subnet that creates a secure communication channel between the frontend service and API Gateway, ensuring all client requests are properly routed through the gateway.

### Deployment View

This view shows the subnets in the server as divided previously:
<img src="./img/Lab5DeployProy.png" width="800">

### Network Architecture Overview

The following table summarizes the network configuration and container distribution:

| Network               | Subnet        | Type    | Connected Containers                                                                                   | Exposed Ports   | Purpose                                     |
| --------------------- | ------------- | ------- | ------------------------------------------------------------------------------------------------------ | --------------- | ------------------------------------------- |
| **frontend_net**      | 172.27.0.0/16 | Public  | runpath_frontend                                                                                       | **5173 (ONLY)** | User-facing presentation layer - sole entry |
| **orchestration_net** | 172.29.0.0/16 | Private | runpath_frontend, api-gateway                                                                          | None            | Secure frontend-gateway communication       |
| **backend_net**       | 172.28.0.0/16 | Private | api-gateway, authentication-service, notification-service, rabbit, routes_app, loki, grafana, promtail | None            | Application logic and services              |
| **db_net**            | 172.30.0.0/16 | Private | routes_postgres, routes_adminer, routes_app                                                            | None            | Data persistence layer                      |

**Critical Security Note**: Only the `runpath_frontend` container exposes port 5173 to the host machine. All other services communicate exclusively through internal Docker networks using the `expose` directive instead of `ports`, making them completely inaccessible from outside the Docker environment. This architecture ensures a **single point of entry** that can be properly secured, monitored, and controlled.

### Detailed Network Segmentation

#### 1. Frontend Network (`frontend_net`)

**Subnet**: 172.27.0.0/16 | **Gateway**: 172.27.0.1

This network segment serves as the **public-facing layer** of the application:

```
Containers:
  - runpath_frontend (172.27.0.2) - Port 5173 exposed to host
```

**Security Properties**:

- **ONLY** the frontend container has ports mapped to the host (5173:5173)
- This is the **sole entry point** for external traffic into the entire system
- Acts as the controlled entry point for end-users
- No direct access to backend services or databases
- All API requests must flow through the orchestration layer
- No other service in the architecture exposes ports externally

**Port Mapping Strategy**:

```
Host (External) → Port 5173 → runpath_frontend → orchestration_net → api-gateway
                                                                    ↓
                                                              Backend Services
                                                                    ↓
                                                                Databases
```

#### 2. Orchestration Network (`orchestration_net`)

**Subnet**: 172.29.0.0/16 | **Gateway**: 172.29.0.1

This network creates a **secure bridge** between the presentation and application layers:

```
Containers:
  - runpath_frontend (172.29.0.3)
  - api-gateway (172.29.0.2)
```

**Security Properties**:

- Internal communication between frontend and API Gateway
- Implements the Gateway pattern as a single entry point
- Enforces authentication, authorization, and rate limiting
- Frontend can only reach backend services through the gateway
- Prevents direct frontend-to-microservice communication

#### 3. Backend Network (`backend_net`)

**Subnet**: 172.28.0.0/16 | **Gateway**: 172.28.0.1

This network hosts the **application logic tier** with all microservices and supporting infrastructure:

```
Containers:
  - api-gateway (172.28.0.2)          # Gateway and routing
  - authentication-service (172.28.0.3) # User authentication
  - rabbit (172.28.0.4)               # RabbitMQ message broker
  - notification-service (172.28.0.5)  # Notifications handling
  - routes_app (172.28.0.6)           # Routes management service
  - loki (172.28.0.7)                 # Log aggregation
  - grafana (172.28.0.8)              # Monitoring and visualization
  - promtail (172.28.0.9)             # Log collection agent
```

**Security Properties**:

- Complete isolation from the public internet
- Microservices communicate only within this network
- API Gateway acts as the only ingress point from orchestration_net
- Message broker (RabbitMQ) enables asynchronous service communication
- Observability stack (Loki, Grafana, Promtail) for monitoring and logging
- No direct database access - services must go through db_net

**Service Communication Flow**:

```
Frontend → Orchestration Net → API Gateway → Backend Services
                                    ↓
                              Message Broker (RabbitMQ)
                                    ↓
                          Async Processing (Notifications)
```

#### 4. Database Network (`db_net`)

**Subnet**: 172.30.0.0/16 | **Gateway**: 172.30.0.1

This network provides **strict data tier isolation**:

```
Containers:
  - routes_adminer (172.30.0.2)      # Database management UI
  - routes_postgres (172.30.0.3)     # PostgreSQL database
  - routes_app (172.30.0.4)          # Routes service with DB access
```

**Security Properties**:

- Complete isolation of data persistence layer
- Only `routes_app` service can access the PostgreSQL database
- `routes_adminer` provides administrative access for database management
- No direct access from frontend or orchestration layers
- Implements least privilege access - only authorized services have DB credentials

**Data Access Pattern**:

```
routes_app (Backend) ←→ routes_postgres (Database)
                  ↓
            routes_adminer (Admin UI)
```

### Implementation Details

#### Port Exposure Strategy: `ports` vs `expose`

A critical security decision in this implementation is the use of `expose` instead of `ports` for all services except the frontend. Understanding this distinction is essential:

**`ports` - Host Port Mapping (Used ONLY for Frontend)**

```yaml
ports:
  - '5173:5173' # Maps host port 5173 to container port 5173
```

- Exposes the service to the **host machine** and potentially external networks
- Allows access from `localhost:5173` or `<host-ip>:5173`
- Used **ONLY** for `runpath_frontend` - the sole entry point

**`expose` - Internal Docker Network Only (Used for All Other Services)**

```yaml
expose:
  - '8080' # Makes port 8080 available ONLY to other containers
```

- Service is accessible **ONLY** within Docker networks
- Cannot be reached from the host machine or external networks
- Other containers in the same network can connect using `http://service-name:8080`
- Used for API Gateway, all backend services, and databases

**Security Impact:**

| Configuration          | Accessibility                                          | Risk Level | Use Case                                |
| ---------------------- | ------------------------------------------------------ | ---------- | --------------------------------------- |
| `ports: - "8080:8080"` | Host + Docker networks + External (if firewall allows) | **HIGH**   | Frontend only                           |
| `expose: - "8080"`     | Docker networks only                                   | **LOW**    | All internal services                   |
| No port config         | Not accessible                                         | **LOWEST** | Services that don't need network access |

This strategy ensures that even if an attacker gains access to the host machine, they **cannot directly access** backend services, the API Gateway, or databases - they can only reach the frontend application.

#### Network Configuration in Docker Compose

To implement this pattern, each service's `docker-compose.yaml` file was configured to connect to its designated network segments. The networks are defined as **external** to ensure they are created and managed independently from individual service stacks.

**Example 1: Backend Service Configuration**

For services that operate exclusively within the backend tier (e.g., authentication-service, notification-service), ports are **NOT exposed to the host** - they only use internal Docker networking:

```yaml
services:
  authentication-service:
    image: authentication-service:latest
    container_name: authentication-service
    expose:
      - '5000' # Internal port only, not mapped to host
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres/authdb
    networks:
      - backend_net
    restart: unless-stopped

networks:
  backend_net:
    external: true
```

**Key Security Feature**: Using `expose` instead of `ports` means the service is **only accessible within the Docker network**, not from the host machine or external networks. This prevents direct access to backend services.

**Example 2: Multi-Network Service Configuration (API Gateway)**

The API Gateway bridges multiple network segments but **does NOT expose ports to the host**. It's only accessible through internal Docker networks:

```yaml
services:
  api-gateway:
    image: nginx:alpine
    container_name: api-gateway
    expose:
      - '8080' # Internal port only, not exposed to host
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - orchestration_net # Communication with frontend
      - backend_net # Communication with microservices
    restart: unless-stopped

networks:
  orchestration_net:
    external: true
  backend_net:
    external: true
```

**Key Security Feature**: The API Gateway is accessible only from within the Docker networks (frontend can reach it via orchestration_net), but it's **not accessible from outside the Docker environment**.

**Example 3: Database-Connected Service Configuration**

For services that require database access (e.g., routes_app), no ports are exposed externally:

```yaml
services:
  routes_app:
    image: routes-service:latest
    container_name: routes_app
    expose:
      - '3000' # Internal port only, not exposed to host
    environment:
      - DB_HOST=routes_postgres
      - DB_PORT=5432
      - DB_NAME=routesdb
    networks:
      - backend_net # Communication with other microservices
      - db_net # Database access
    depends_on:
      - routes_postgres
    restart: unless-stopped

networks:
  backend_net:
    external: true
  db_net:
    external: true
```

**Key Security Feature**: The routes service can communicate with both the backend services and the database, but is **completely isolated from external access**.

**Example 4: Frontend Service Configuration (ONLY Public Exposure)**

The frontend is the **ONLY** service with ports mapped to the host, making it the sole entry point:

```yaml
services:
  runpath_frontend:
    image: runpath-frontend:latest
    container_name: runpath_frontend
    ports:
      - '5173:5173' # ONLY the frontend exposes ports to host
    networks:
      - frontend_net
      - orchestration_net
    depends_on:
      - api-gateway
    restart: unless-stopped

networks:
  frontend_net:
    external: true
  orchestration_net:
    external: true
```

**Critical Security Principle**: By exposing ports **only on the frontend**, we ensure:

- All external traffic must enter through the frontend application
- Backend services, API Gateway, and databases are completely unreachable from outside the Docker network
- Attackers cannot directly target internal services even if they discover their existence
- This creates a single, controlled entry point that can be monitored and protected

### Network Creation and Validation

#### Creating External Networks

Before deploying the services, create the external networks manually:

```bash
# Create frontend network
docker network create --driver bridge --subnet 172.27.0.0/16 frontend_net

# Create orchestration network
docker network create --driver bridge --subnet 172.29.0.0/16 orchestration_net

# Create backend network
docker network create --driver bridge --subnet 172.28.0.0/16 backend_net

# Create database network
docker network create --driver bridge --subnet 172.30.0.0/16 db_net
```

#### Verifying Network Segmentation

**1. List all Docker networks:**

```bash
docker network ls
```

Expected output should include the four custom networks:

```
NETWORK ID     NAME                DRIVER    SCOPE
8053be48d79a   frontend_net        bridge    local
7277c1ae5d84   orchestration_net   bridge    local
f6ed8b1c1459   backend_net         bridge    local
4763ab4b4b24   db_net              bridge    local
```

**2. Inspect network connectivity:**

Verify that containers are properly segmented by inspecting each network:

```bash
# Inspect frontend network
docker network inspect frontend_net

# Inspect orchestration network
docker network inspect orchestration_net

# Inspect backend network
docker network inspect backend_net

# Inspect database network
docker network inspect db_net
```

**3. Test network isolation:**

Execute connectivity tests to validate segmentation:

```bash
# Test 1: Verify frontend cannot directly access backend services
docker exec runpath_frontend sh -c "nc -zv authentication-service 5000"
# Expected: Connection refused or name resolution failure

# Test 2: Verify frontend can reach API Gateway through orchestration network
docker exec runpath_frontend sh -c "curl -f http://api-gateway:8080/health"
# Expected: HTTP 200 OK

# Test 3: Verify backend services cannot directly access database
docker exec authentication-service sh -c "nc -zv routes_postgres 5432"
# Expected: Connection refused (unless service is routes_app)

# Test 4: Verify routes_app can access database
docker exec routes_app sh -c "nc -zv routes_postgres 5432"
# Expected: Connection successful (port 5432 open)
```

### Security Benefits Achieved

This implementation delivers the following security guarantees:

1. **Single Entry Point**: Only the frontend container exposes ports (5173) to the host machine, creating a controlled, monitorable entry point that eliminates direct access to internal services

2. **Port Exposure Minimization**: Using `expose` instead of `ports` for all internal services ensures they are completely unreachable from outside the Docker network, even from the host machine

3. **Defense in Depth**: Multiple network layers prevent direct access to sensitive resources - attackers must traverse frontend → orchestration → backend → database

4. **Blast Radius Containment**: Compromise of one layer doesn't grant access to others; even host-level compromise cannot directly reach backend services or databases

5. **Principle of Least Privilege**: Services only have access to networks they require, and no service except frontend can be accessed from outside

6. **Traffic Control**: All requests flow through defined choke points (API Gateway), which can enforce authentication, rate limiting, and request validation

7. **Data Protection**: Database access is strictly limited to authorized services; databases are isolated in their own network with no external exposure

8. **Attack Surface Reduction**: By not exposing backend services, API Gateway, or databases to the host, we eliminate entire classes of attacks (direct service exploitation, port scanning effectiveness)

9. **Monitoring and Observability**: Dedicated observability stack (Loki, Grafana, Promtail) provides visibility into cross-network traffic patterns and anomaly detection

10. **Audit Trail**: Clear network boundaries and single entry point enable comprehensive security logging and forensic analysis
