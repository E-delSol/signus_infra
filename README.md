# 🏗️ Signus Infrastructure

## 📌 Overview

This repository contains the infrastructure, deployment configuration, and technical documentation for the **Signus** platform.

It defines how the system is deployed, connected, and exposed in production, including:

- server setup
    
- Docker services
    
- networking
    
- reverse proxy (Nginx)
    
- security considerations
    

---

## 🧱 Repository Structure

```text
signus_infra/
├── docs/
│   └── infrastructure/
│       ├── 01-server-setup.md
│       ├── 02-docker-setup.md
│       ├── 03-networking.md
│       ├── 04-deployment-backend.md
│       ├── 05-proxy-nginx.md
│       ├── 06-security.md
│       └── 07-websockets-nginx.md
├── proxy/
│   └── nginx.conf
└── deployment/
```

---

## 🌐 System Architecture

```text
Client (Android)
   ↓
Nginx (Reverse Proxy)
   ↓
Backend (Ktor API)
   ↓
PostgreSQL
```

- **Nginx** acts as the single public entry point.
    
- **Backend** is not directly exposed to the internet.
    
- **Database** is fully isolated inside Docker network.
    

---

## 🐳 Services

### Reverse Proxy

- Nginx
    
- Handles HTTP traffic and WebSocket upgrade
    
- Exposes port `80`
    

### Backend

- Ktor application
    
- Runs inside Docker
    
- Connected to internal network only
    

### Database

- PostgreSQL 16
    
- Persistent volume enabled
    

---

## 🔌 Networking

- Docker network used for internal communication
    
- Services communicate via container names (DNS)
    
- Proxy is attached to backend network via external network
    

See:

```text
docs/infrastructure/03-networking.md
```

---

## 🔌 WebSockets

WebSockets are used as the **primary real-time channel**.

Important:

- Nginx must support connection upgrade
    
- Missing configuration leads to silent fallback to polling
    

See:

```text
docs/infrastructure/07-websockets-nginx.md
```

---

## 🔐 Security

- SSH key-based authentication only
    
- Fail2Ban enabled
    
- Minimal exposed ports:
    
    - `22` → SSH
        
    - `80` → HTTP
        
- Backend and DB not publicly exposed
    

See:

```text
docs/infrastructure/06-security.md
```

---

## 🚀 Deployment

The backend is deployed using Docker Compose:

- `signus-backend`
    
- `signus-db`
    
- `signus-proxy`
    

Typical workflow:

```bash
docker-compose up -d
```

---

## ⚠️ Important Notes

### WebSocket support is NOT automatic in Nginx

This project explicitly requires:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

Without this:

- WebSocket fails
    
- App falls back to polling
    
- Backend load increases significantly
    

---

## 🧠 Design Principles

- minimal exposure
    
- clear separation of concerns
    
- infrastructure as code (where possible)
    
- reproducible environments
    
- observability via logs
    

---

## 🔗 Related Repositories

- `signus_app` → Android client
    
- `signus_back` → Backend API
    

---

## 📌 Status

Current state:

- backend deployed and reachable
    
- reverse proxy configured
    
- WebSocket working through Nginx
    
- real-time communication restored
    
- fallback polling minimized
    

---

## 🔮 Future Improvements

- HTTPS (Let's Encrypt)
    
- domain configuration
    
- CI/CD pipeline
    
- environment separation (dev / staging / prod)
    
- centralized logging and monitoring
    

---