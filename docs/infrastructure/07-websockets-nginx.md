# 🔌 WebSockets + Nginx — Signus

## 📌 Objective

Document the configuration required for the Nginx proxy to properly support WebSocket connections to the backend.

---

## 🧱 Context

During backend deployment in the remote environment, anomalous behavior was detected:

- the Android app was making periodic requests to `GET /partner`
    
- approximate frequency: every 3 seconds
    
- behavior persisted even without user interaction
    

---

## 🔍 Observed Symptom

Backend logs:

```text
GET /ws → 400 Bad Request
GET /partner → repeated every ~3s
```

---

## 🧠 Root Cause

The Nginx proxy was configured only for standard HTTP traffic.

Without additional configuration:

- Nginx **does not correctly perform the connection upgrade**
    
- the backend receives the `/ws` request as normal HTTP
    
- the WebSocket handshake fails
    
- `400 Bad Request` is returned
    

---

## 🔄 Consequence in the App

The partner data flow follows this logic:

```text
WebSocket → main channel
Polling HTTP → fallback
```

When the WebSocket fails:

- the app falls back
    
- continuous polling is executed:
    

```kotlin
while (isActive) {
    delay(3000)
    fetchPartner()
}
```

👉 Result: unnecessary constant traffic

---

## ⚙️ Required Nginx Configuration

To support WebSockets, it is mandatory to add:

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

---

## ✅ Final Configuration

```nginx
events {}

http {
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://signus-backend:8080;

            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

---

## 🧪 Validation

After applying the configuration:

### Before

```text
GET /ws → 400 Bad Request
GET /partner → every ~3s
```

### After

- the `400 /ws` error disappears
    
- the WebSocket is established correctly
    
- polling stops being continuous
    
- traffic is significantly reduced
    

---

## 📌 Best Practices

- always configure Nginx to support WebSockets in real-time projects
    
- avoid assuming that `proxy_pass` works automatically for sockets
    
- always validate the handshake in logs (`/ws`)
    
- observe indirect effects (polling fallback, excessive traffic)
    

---

## ⚠️ Risk if Not Applied

- silent degradation to polling
    
- increased backend load
    
- higher battery consumption on the client
    
- loss of real-time functionality
    

---

## 🧠 Conclusion

WebSocket support in Nginx is not automatic and requires explicit configuration.

In systems with polling fallback, a handshake failure may not break the app, but it can seriously degrade its behavior.

This case demonstrates the importance of:

- observing logs
    
- understanding fallback strategies
    
- validating infrastructure, not just code
    

---
