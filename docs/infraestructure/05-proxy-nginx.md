# 🌐 Proxy Nginx — Signus

## 📌 Objective

Configure an Nginx reverse proxy as the only public entry point to the Signus system.

---

## 🧱 Proxy Role

The Nginx proxy is responsible for:

- receiving HTTP traffic from the Internet
    
- forwarding requests to the backend
    
- hiding the internal infrastructure
    
- centralizing access to the application
    

---

## 🌐 Network Flow

```text
Client
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

## 📁 Location

```text
/opt/projects/signus/proxy
```

---

## 📦 Docker Compose

```yaml
services:
  proxy:
    image: nginx:latest
    container_name: signus-proxy
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    restart: unless-stopped
    networks:
      - backend_net

networks:
  backend_net:
    external: true
    name: backend_signus_net
```

---

## ⚙️ Nginx Configuration

File:

```text
nginx.conf
```

---

### Current Configuration

```nginx
events {}

http {
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://signus-backend:8080;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

---

## 🧠 Explanation

### `proxy_pass`

```nginx
proxy_pass http://signus-backend:8080;
```

👉 Forwards all requests to the backend.

---

### DNS Resolution

- `signus-backend` is the container name
    
- Docker resolves it automatically within the network
    

---

### Headers

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

👉 They allow the backend to know:

- the client's real IP
    
- the original protocol
    
- the requested host
    

---

## ⚠️ Identified Issue

### Error:

```text
host not found in upstream "signus-backend"
```

---

## 🧠 Cause

The proxy was on a different network:

```text
proxy_default
```

The backend was on:

```text
backend_signus_net
```

👉 No shared network → no DNS resolution

---

## ✅ Solution

The proxy is connected to the backend network:

```yaml
networks:
  backend_net:
    external: true
    name: backend_signus_net
```

---

## 🔄 Proxy Restart

```bash
docker-compose restart
```

---

## 🔍 Verification

```bash
docker ps
```

Expected result:

```text
signus-proxy → Up
```

---

## 🌐 Browser Test

```text
http://<PUBLIC_IP>
```

---

### Expected Result

- access to the backend through the proxy
    
- correct HTTP responses (200, 404, etc.)
    

---

## 📌 Expected Behavior

### Route `/`

```text
404 Not Found
```

👉 Normal, since the backend does not define that route.

---

### Actual Routes

```text
/auth/register
/auth/login
```

👉 They work correctly through the proxy.

---

## 🔐 Security

### Single Entry Point

Only port 80 is publicly exposed.

---

### Protected Backend

- port 8080 not accessible from the Internet (OCI)
    
- only accessible internally
    

---

### Isolated Database

- not exposed
    
- accessible only from the backend
    

---

## 📌 Applied Best Practices

- proxy as the only entry point
    
- no direct exposure of the backend
    
- use of the internal Docker network
    
- use of DNS names instead of IPs
    
- minimal and clear configuration
    

---

## 🔮 Future Improvements

- HTTPS (Let's Encrypt)
    
- HTTP → HTTPS redirection
    
- rate limiting
    
- access logs
    
- compression (gzip)
    
- caching
    

---

## 🚀 Final State

- operational proxy
    
- backend accessible through Nginx
    
- clean and decoupled architecture
    
- system ready to evolve to full production
    

---
