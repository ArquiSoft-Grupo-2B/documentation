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

The Network Segmentation Pattern is an architectural tactic for Limit Access (a form of Attack Resistance). It involves partitioning a network into distinct, isolated logical subnets, specifically separating Public (Internet-facing, uses public IPs) and Private (sensitive resources, uses private IPs) areas.

Its core purpose is to strictly control traffic flow between these segments and prevent the lateral spread of a security compromise. By isolating critical assets in the Private Subnet, the pattern minimizes their exposure to untrusted networks like the Internet, ensuring only inspected and authorized traffic can reach them.

### Quality scenario addressed

The Network Segmentation Pattern primarily addresses Confidentiality and Integrity, and contributes significantly to Availability.

**Confidentiality**

    It shields sensitive data and internal systems (located in the Private Subnet) from unauthorized disclosure by blocking direct access from external or less-trusted network segments.

**Integrity**

    By controlling the traffic flow, it prevents unauthorized modification or deletion of data by restricting what an attacker can do even if they compromise a public-facing segment.

**Availability (Contribution)**

    It limits the blast radius of an attack or failure. By containing a security incident within a specific network segment, the pattern ensures that critical services in other segments remain operational and available to users.

## Example implementation

### Components & Connectors (C&C) View

*Hacer anotacion de que es simplemente descriptiva para el ejemplo, pero no es la vista que representa el patrón.*

### Deployment View 


*Description of the example scenario*

### Steps to follow

**1. Retrieve the Software System**

Clone the application repository from the designated source using the `git clone` command:

```bash
git clone [REPOSITORY_URL]
```

**2. Build and Launch Containers**

Navigate to the application directory and deploy the services. The `--build` flag ensures that all necessary service images are built before the containers are launched.

```bash
cd sw-example
docker compose up --build
```

**3. Verify Docker Network Creation**

List all networks managed by the Docker daemon to confirm the creation of the custom network provisioned by Docker Compose:

```bash 
docker network ls
```

**4. Inspect Network Structure and Connected Containers**

Use the `docker network inspect command`, referencing the specific network identifier (ID or Name), to examine the configuration details, including IP addressing, network scope, and, **most importantly**, the list of connected containers within that isolated network segment.

```bash
docker network inspect [network_identifier]
```

**5. Test connectivity between networks**

Validate inter-network communication by testing connectivity between containers located in different network domains. This step confirms whether the implemented network segmentation correctly isolates or allows communication across defined boundaries.

- **List Active Containers and Their IP Addresses**

Retrieve container names and IP addresses for each network to identify communication endpoints:

```bash
docker ps
docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.NetworkID}}: {{.IPAddress}}{{end}}' $(docker ps -q)
```

- **Execute Connectivity Tests Between Containers**

*Especificar las relaciones o test de conexión que se deben hacer*



## Project implementation



### Deployment View

