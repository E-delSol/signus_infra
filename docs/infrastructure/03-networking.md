# 🌐 Networking — Signus

## 📌 Objective

Define and document the network architecture between the different Signus services deployed with Docker:

- Proxy (Nginx)
    
- Backend (Ktor)
    
- Database (PostgreSQL)
    

---

## 🧱 Network Architecture

### Main Flow

```text
Internet
   ↓
[Port 80 - OCI]
   ↓
signus-proxy (Nginx)
   ↓
signus-backend (Ktor)
   ↓
signus-db (PostgreSQL)
```

---

## 🔌 Docker Networks

Docker creates virtual networks that allow communication between containers using internal DNS names.

### Existing Networks

```bash
docker network ls
```

Real example:

```text
backend_signus_net
proxy_default
```

---

## ⚠️ Identified Issue

### Symptom

The proxy could not connect to the backend:

```text
host not found in upstream "signus-backend"
```

### Context

- Proxy defined in `/opt/projects/signus/proxy`
    
- Backend defined in `/opt/projects/signus/backend`
    
- Each `docker-compose` creates its own isolated network
    

---

## 🧠 Root Cause

Each `docker-compose` automatically creates its own network:

```text
proxy → proxy_default
backend → backend_signus_net
```

👉 Containers **do not share a network by default**

👉 Therefore:

- `signus-proxy` cannot resolve `signus-backend`
    
- Docker's internal DNS does not work across different networks
    

---

## 🔍 Diagnosis

```bash
docker ps
docker network ls
docker logs signus-proxy
```

Key error:

```text
nginx: [emerg] host not found in upstream "signus-backend"
```

---

## ✅ Applied Solution

### Use of a Shared External Network

The backend network is chosen as the main network.

---

### Proxy Configuration

```yaml
networks:
  backend_net:
    external: true
    name: backend_signus_net
```

Assignment to the service:

```yaml
services:
  proxy:
    networks:
      - backend_net
```

---

## 🧠 What This Means

- `external: true` → the network already exists
    
- `backend_signus_net` → network created by the backend compose
    
- the proxy joins that network
    

---

## 🔗 Result

All services now share the same network:

```text
signus-proxy
signus-backend
signus-db
   ↓
backend_signus_net
```

---

## 🌐 Internal DNS Resolution

Docker allows containers to be resolved by name:

```text
signus-backend → internal IP
signus-db → internal IP
```

Therefore, Nginx can use:

```nginx
proxy_pass http://signus-backend:8080;
```

---

## 🔄 Actual Communication Flow

```text
Client → Nginx → signus-backend → signus-db
```

Everything happens within the Docker network.

---

## ⚠️ Important Considerations

### Default Isolation

- Each compose creates its own network
    
- There is no automatic communication between projects
    

---

### Port Exposure

- `80` → exposed (public)
    
- `8080` → exposed locally (not public through OCI)
    
- `5432` → not exposed (internal only)
    

---

## 📌 Applied Best Practices

- ✅ Use of a dedicated network per project
    
- ✅ Use of an external network for communication between services
    
- ✅ Name-based resolution (not IP-based)
    
- ❌ avoid hardcoding IP addresses
    
- ✅ keep the DB isolated
    

---

## 🔐 Network Security

- The database is not accessible from outside
    
- The backend should only be accessible from the proxy
    
- The proxy is the only public entry point
    

---

## 🚀 Final State

- internal communication working
    
- proxy correctly connected to the backend
    
- decoupled and scalable architecture
    

---

## 🔮 Future Improvement

- remove exposure of `8080` on the host
    
- separate networks by environment (dev / staging / prod)
    
- introduce a system-level firewall (`ufw`)
    

---
