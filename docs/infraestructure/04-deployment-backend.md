# 🚀 Backend Deployment — Signus

## 📌 Objective

Deploy the Signus backend (Ktor) together with its PostgreSQL database in a Dockerized production-ready environment.

---

## 🧱 Components

The backend consists of two main services:

```text
signus-backend → API Ktor
signus-db      → PostgreSQL
```

---

## 📁 Location

```text
/opt/projects/signus/backend
```

---

## 📦 Docker Compose

Main file:

```text
docker-compose.yml
```

---

### Configuration

```yaml
services:
  db:
    image: postgres:16
    container_name: signus-db
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - signus_db:/var/lib/postgresql/data
    networks:
      - signus_net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 5s
      timeout: 5s
      retries: 20
    restart: unless-stopped

  api:
    build: .
    container_name: signus-backend
    depends_on:
      db:
        condition: service_healthy
    env_file:
      - .env
    environment:
      DB_HOST: db
      DB_PORT: 5432
    networks:
      - signus_net
    ports:
      - "8080:8080"
    restart: unless-stopped

volumes:
  signus_db:

networks:
  signus_net:
```

---

## 🐘 Database

### PostgreSQL

- version: 16
    
- container: `signus-db`
    
- persistent volume: `signus_db`
    

---

### Persistence

```yaml
volumes:
  - signus_db:/var/lib/postgresql/data
```

👉 Ensures that data survives restarts or recreations.

---

### Healthcheck

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
```

👉 Allows the backend to wait until the DB is ready before starting.

---

## ⚙️ Backend (Ktor)

### Build

```yaml
build: .
```

👉 The image is built from the project's `Dockerfile`.

---

### Environment Variables

```yaml
env_file:
  - .env
```

---

## 🔐 `.env` File

Location:

```text
/opt/projects/signus/backend/.env
```

---

### Database

```env
DB_HOST=db
DB_PORT=5432
DB_NAME=signus
DB_USER=signus
DB_PASSWORD=********
```

---

### JWT

```env
JWT_SECRET=********
JWT_ISSUER=signus-api
JWT_AUDIENCE=signus-clients
JWT_REALM=signus
JWT_EXPIRATION_TIME=3600000
```

---

## 🔄 Deployment Process

### Repository Clone

```bash
git clone https://github.com/E-delSol/signus_back.git .
```

---

### `.env` Creation

```bash
cp .env.example .env
```

---

### Startup

```bash
docker-compose up -d
```

---

## ⚠️ Identified Issue

### Error:

```text
KeyError: 'ContainerConfig'
```

---

### Cause

- use of Docker Compose v1
    
- attempt to recreate containers
    

---

### Applied Solution

```bash
docker ps -a
docker rm <contenedor_conflictivo>
docker-compose up -d api
```

---

## 🔍 Verification

### Container Status

```bash
docker ps
```

Expected result:

```text
signus-backend → Up
signus-db      → Up (healthy)
```

---

## 🌐 Functional Tests

### Registration

```bash
curl -X POST http://localhost/auth/register
```

✔ 201 Created

---

### Login

```bash
curl -X POST http://localhost/auth/login
```

✔ 200 OK  
✔ returns `accessToken`

---

## 🔐 JWT Validation

The generated token includes:

```json
{
  "iss": "signus-api",
  "aud": "signus-clients"
}
```

---

## 🔗 Connection to the Proxy

The backend is not accessed directly from the Internet.

All traffic passes through:

```text
signus-proxy → signus-backend
```

---

## ⚠️ Considerations

### Port Exposure

```yaml
ports:
  - "8080:8080"
```

👉 Only necessary for testing.

---

## 🔮 Future Improvement

- remove exposure of `8080`
    
- use only the internal Docker network
    
- add a healthcheck to the backend
    
- structured logs
    

---

## 📌 Applied Best Practices

- backend / DB separation
    
- use of environment variables
    
- data persistence
    
- startup control with healthcheck
    
- real functional validation
    

---

## 🚀 Final State

Backend:

- deployed correctly
    
- connected to the database
    
- accessible via the proxy
    
- authentication working
    
- ready for future evolution
    

---
