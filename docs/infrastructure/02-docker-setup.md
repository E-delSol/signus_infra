# 🐳 Docker Setup — Signus

## 📌 Objective

Prepare the Docker container environment to run Signus services in an isolated, reproducible, and scalable way.

---

## 🧱 Docker's Role in the Architecture

Docker is used as the foundation to:

- isolate services (backend, database, proxy)
    
- ensure consistency across environments
    
- simplify deployments and maintenance
    
- prepare the system for future scalability
    

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

## 🔧 Docker Compose

Docker Compose is used to define multi-container services.

---

## ❌ Identified Issue: Docker Compose v1

### Error Found

```text
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

```bash
docker ps -a
```

Identify containers in the `Exited` state.

```bash
docker rm <container_name>
```

Real example:

```bash
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

## 🔄 Adopted Deployment Flow

```text
1. docker-compose down (if applicable)
2. docker rm conflicting containers (if necessary)
3. docker-compose up -d
```

---

## 📌 Applied Best Practices

- ✅ use of one container per service
    
- ✅ persistence through volumes
    
- ✅ network isolation
    
- ✅ consistent naming
    
- ⚠️ avoid dependencies on obsolete tools
    

---

## 🚀 Final State

Docker:

- correctly installed
    
- running without root privileges
    
- managing multiple services
    
- with a clear error-resolution strategy
    

---

## 🔮 Recommended Future Improvement

Migrate to official Docker + Compose v2:

```bash
docker compose
```

Benefits:

- active support
    
- better compatibility
    
- fewer recreation errors
    

---