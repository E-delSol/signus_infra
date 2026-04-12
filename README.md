# 🏗️ Signus Infrastructure

Production-ready infrastructure and deployment architecture for a real-time system.

This repository documents how **Signus** is deployed in a real environment using Docker, Nginx, and a WebSocket-enabled backend.

---

## 🚀 Project Summary

This repository demonstrates a production-oriented infrastructure setup for a real-time application stack.

It includes:

- **Nginx** as the public entry point
    
- **Docker** for service isolation and reproducible deployment
    
- **Ktor + PostgreSQL** running behind internal networking
    
- **WebSockets** properly handled at the proxy layer
    
- **Technical documentation** capturing real deployment decisions and issues
    

---

## 🧩 What this repository demonstrates

- Designing and deploying a real-world backend infrastructure
    
- Running containerized services with Docker Compose
    
- Configuring Nginx as a reverse proxy for HTTP and WebSockets
    
- Debugging real deployment issues (WebSocket fallback to polling)
    
- Structuring infrastructure documentation for maintainability
    

---

## 📌 Overview

`signus_infra` is the infrastructure repository of the Signus ecosystem. It captures how the system is deployed, connected, and secured in a production-oriented setup.

Key characteristics:

- Nginx acts as the single public entry point
    
- The backend and database run inside Docker containers
    
- Internal services communicate through Docker networking
    
- Public exposure is minimized by design
    
- WebSocket behavior is validated at the infrastructure level
    

---

## 🌐 Part of the Signus Ecosystem

Signus is structured as a multi-repository system:

- [signus_app](https://github.com/E-delSol/signus_app) — Android client
    
- [signus_back](https://github.com/E-delSol/signus_back) — Backend API (Ktor + WebSockets)
    
- **signus_infra** — Infrastructure, deployment, and technical documentation (this repository)
    

---

## 🏗️ Architecture

```text
Android Client
   ↓
Nginx (public reverse proxy)
   ↓
Ktor Backend API
   ↓
PostgreSQL
```

Infrastructure design:

- Nginx exposes the public HTTP entry point
    
- Backend services are proxied internally and not directly exposed
    
- PostgreSQL remains isolated behind Docker networking
    
- Service-to-service communication relies on Docker DNS
    

---

## 🧰 Stack and Infrastructure Components

- **Docker** — containerized service execution
    
- **Nginx** — reverse proxy and public ingress
    
- **Ktor** — backend application layer
    
- **PostgreSQL** — persistent data storage
    
- **WebSockets** — real-time communication
    
- **Docker networking** — service isolation
    

Repository structure highlights:

- [proxy/nginx.conf](proxy/nginx.conf) — Nginx proxy configuration
    
- `deployment/` — deployment workspace
    
- `docs/infrastructure/` — detailed technical documentation
    

---

## 🔌 Real-Time / WebSocket Deployment Note

One of the key infrastructure findings in this project is that **WebSockets behind Nginx require explicit configuration**.

Without:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

the backend receives `/ws` as a normal HTTP request, the WebSocket handshake fails, and the client may silently fall back to polling.

### Key takeaway

- WebSocket support is not automatic at the proxy layer
    
- Silent fallback to polling can hide deployment issues
    
- Real-time systems require infrastructure-level validation
    

📄 Full explanation:

- [WebSockets + Nginx](docs/infrastructure/07-websockets-nginx.md)
    

---

## 🔐 Security

The infrastructure follows a conservative, production-oriented baseline:

- SSH key-based access
    
- Minimal public exposure
    
- Fail2Ban protection
    
- Backend not directly exposed to the Internet
    
- Database isolated from public access
    
- Environment-based handling of sensitive configuration
    

---

## 📚 Documentation Index

Detailed infrastructure documentation:

- [01 - Server Setup](docs/infrastructure/01-server-setup.md)
    
- [02 - Docker Setup](docs/infrastructure/02-docker-setup.md)
    
- [03 - Networking](docs/infrastructure/03-networking.md)
    
- [04 - Backend Deployment](docs/infrastructure/04-deployment-backend.md)
    
- [05 - Proxy Nginx](docs/infrastructure/05-proxy-nginx.md)
    
- [06 - Security](docs/infrastructure/06-security.md)
    
- [07 - WebSockets + Nginx](docs/infrastructure/07-websockets-nginx.md)
    

---

## 🧠 Engineering Highlights

- End-to-end deployment path instead of isolated configuration snippets
    
- Clear separation between ingress, application, and data layers
    
- Real-world debugging of WebSocket and Nginx interaction
    
- Controlled Docker networking for service isolation
    
- Documentation treated as part of the engineering deliverable
    

---

## 🔮 Future Improvements

- HTTPS with Let's Encrypt
    
- Domain configuration and host hardening
    
- CI/CD automation for deployment workflows
    
- Environment separation (dev / staging / production)
    
- Centralized logging and monitoring
    

---

## 📄 License

- [LICENSE](LICENSE)
    

---

## 👤 Author

E-delSol

---
