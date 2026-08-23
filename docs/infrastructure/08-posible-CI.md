# 🐳 Docker Setup — Signus

## 📌 Objective

Prepare the Docker container environment to run Signus services in an isolated, reproducible, and scalable way.

Additionally, define how Docker integrates with the CI/CD pipeline for automated deployments.

---

## 🧱 Docker's Role in the Architecture

Docker is used as the foundation to:

- isolate services (backend, database, proxy)
- ensure consistency across environments
- simplify deployments and maintenance
- prepare the system for future scalability
- enable reproducible deployments via container images

---

## 🏗️ Deployment Architecture

The system follows a Docker-based CI/CD workflow:

```text
GitHub (signus_back)
   ↓
Build Docker image
   ↓
Push to GHCR
   ↓
Oracle VM
   ↓
docker pull + restart container
```
### Responsibilities

- GitHub Actions → build & publish images
- GHCR → container registry
- Oracle VM → runtime environment
- Docker → container execution
- deploy.sh → deployment orchestration

---

## ⚙️ Docker Installation

Docker is installed on the Ubuntu server.

### Verification

```bash
docker --version
```

---

## 👤 User Permissions

The `ops` user is allowed to run Docker without `sudo`:

```bash
sudo usermod -aG docker ops
```

Apply changes:

```bash
newgrp docker
```

---

## 🧪 Functionality Verification

Example test container:

```bash
docker run -d -p 8080:80 nginx
```

This makes it possible to verify:

- Docker functionality
    
- network connectivity
    
- firewall rules (OCI)
    

---

## ⚠️ Port Exposure

During testing, port 8080 is temporarily opened in OCI.

⚠️ Important:

- It is removed after validation
    
- It is not kept open in production
    

---

## 🔐 GHCR Authentication

The VM must authenticate against GitHub Container Registry to pull private images.

### Login

```bash
echo $GHCR_TOKEN | docker login ghcr.io -u <github-username> --password-stdin
```

### Requirements

- Personal Access Token (PAT)
- Required scope: `read:packages`

---

## 🚀 Deployment Script

The deployment process is executed through a script located on the VM:

```bash
/opt/signus/deploy.sh <version>
```

### Responsibilities

- pull the requested image version
- stop the running container
- remove the old container
- start the new version

### Example Implementation

```bash
#!/bin/bash

VERSION=$1
IMAGE="ghcr.io/<user>/signus_back:$VERSION"
CONTAINER="signus-back"

echo "Deploying version $VERSION..."

docker pull $IMAGE

docker stop $CONTAINER || true
docker rm $CONTAINER || true

docker run -d \
  --name $CONTAINER \
  -p 8080:8080 \
  $IMAGE
```
### Notes

- `|| true` prevents failure if the container does not exist
- the script is idempotent and safe to re-run

---

## 🔁 CI/CD Integration

The deployment process is automated via GitHub Actions.

### Trigger

- creation of a version tag (e.g. `v1.0.0`)

### Pipeline Steps

1. build backend (Ktor)
2. build Docker image
3. push image to GHCR
4. connect to VM via SSH
5. execute `deploy.sh`

---

## 🧪 Manual Deployment (Fallback)

Deployment can be triggered manually for testing or recovery:

```bash
/opt/signus/deploy.sh v1.0.0
```

---

## 📂 Directory Structure (VM)

```
/opt/signus/
  ├── deploy.sh
```

---

## 🔧 Docker Compose

Docker Compose is used to define multi-container services.

⚠️ Current status:

- not used in production deployment
- reserved for future multi-service setups (DB, proxy, etc.)

---

## ❌ Identified Issue: Docker Compose v1

### Error Found

```
KeyError: 'ContainerConfig'
```

### Context

- Use of `docker-compose` v1.29.2
- Attempt to recreate containers (`up --force-recreate`)
- Incompatibility with modern Docker

---

## 🧠 Cause

Docker Compose v1:

- is obsolete
- is not fully compatible with current Docker versions
- fails when handling metadata from older containers

---

## ✅ Applied Solution

### Manual Removal of Conflicting Containers

```
docker ps -a
```

Identify containers in the `Exited` state.

```
docker rm <container_name>
```

Real example:

```
docker rm dfc0b5c8e97c_signus-backend
```

---

### Adopted Strategy

Instead of recreating containers:

- ❌ avoid `--force-recreate`
- ✅ remove the container manually
- ✅ create it from scratch with `docker-compose up`

---

## 📦 Naming Convention

A clear naming scheme is defined:

```text
signus-proxy
signus-backend
signus-db
```

### Rationale

- clarity in logs
- ease of debugging
- consistency across services
- readiness for multiple projects

---

## 🔄 Adopted Deployment Flow (Current)

Production deployment:

```text
1. docker pull (new image)
2. docker stop (existing container)
3. docker rm (old container)
4. docker run (new version)
```

Legacy / local (compose):

```text
1. docker-compose down
2. docker rm conflicting containers (if necessary)
3. docker-compose up -d
```

---

## 📌 Applied Best Practices

- ✅ one container per service
- ✅ immutable deployments (new container per version)
- ✅ container registry (GHCR)
- ✅ automated CI/CD pipeline
- ✅ consistent naming
- ⚠️ avoid obsolete tooling

---

## 🚀 Final State

Docker:

- correctly installed
- running without root privileges
- integrated with CI/CD
- used as the deployment runtime
- supporting versioned, reproducible releases

---

## 🔮 Recommended Future Improvement

### Docker Compose v2

```
docker compose
```

### When to adopt

- introduction of database (PostgreSQL)
- reverse proxy (NGINX / Traefik)
- multi-service orchestration

### Benefits

- active support
- better compatibility
- cleaner multi-container management

---