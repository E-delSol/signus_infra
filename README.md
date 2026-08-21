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

## Demo Launcher

One-command demo that sets up Signus with two linked users on Android emulators.

### Prerequisites

- Java/JDK 11+
- Android SDK (`ANDROID_HOME` set)
- `adb` and `emulator` in PATH
- Docker and Docker Compose
- AVDs: `User1_light` and `User2_light`
- Python 3 (for JSON parsing in the script)

### Running the demo

```bash
./demo/demo.sh
```

This will:
1. Check all prerequisites
2. Start the backend (PostgreSQL + Ktor) in Docker
3. Create two users (Alice & Bob) and link them
4. Build the demo APK
5. Launch two visible emulators
6. Install the app and inject authentication tokens
7. Open Signus on both devices ready to use

### What it does

| Step | Description |
|------|-------------|
| Backend | Starts Docker containers on port 8080 (reuses if already running) |
| Users | Creates `alice@signus-demo.com` and `bob@signus-demo.com` |
| Linking | Creates a pairing session and confirms it |
| APK | Builds `assembleDemo` variant (BASE_URL=http://10.0.2.2:8080) |
| Emulators | Launches `User1_light` and `User2_light` visibly |
| Auth | Injects JWT tokens via BroadcastReceiver (no UI automation) |

### Stopping the demo

The script does not close emulators or the backend. To stop them:

```bash
# Stop emulators
adb -s emulator-5554 emu kill
adb -s emulator-5556 emu kill

# Stop backend
cd /path/to/signus_back && docker compose down
```

### Configuration

Environment variables for custom paths:

```bash
export SIGNUS_BACKEND_DIR=/path/to/signus_back
export SIGNUS_APP_DIR=/path/to/signus_app
./demo/demo.sh
```

### Creating AVDs

If the required AVDs don't exist:

```bash
$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    -n User1_light -k "system-images;android-33;google_apis;x86_64" \
    -d "pixel_4"

$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    -n User2_light -k "system-images;android-33;google_apis;x86_64" \
    -d "pixel_4"
```
