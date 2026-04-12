# 🔐 Security — Signus

## 📌 Objective

Define the security measures applied to the Signus infrastructure during phase 1 of deployment.

---

## 🧱 Applied Principles

- **Minimal exposure**
    
- **Controlled access**
    
- **Separation of responsibilities**
    
- **Defense in depth**
    

---

## 👤 Server Access

### Operational User

- user: `ops`
    
- privileges: `sudo`
    
- use of `root`: ❌ avoided
    

---

## 🔑 SSH

### Authentication

- access via public key
    
- file:
    

```text
/home/ops/.ssh/authorized_keys
```

---

### Configuration

```bash
sudo nano /etc/ssh/sshd_config
```

```text
PasswordAuthentication no
```

---

### Result

- ❌ password access disabled
    
- ✅ key-based access only
    

---

## 🛡️ Protection Against Attacks

### Fail2Ban

Protects against repeated SSH access attempts.

---

### Installation

```bash
sudo apt install fail2ban
```

---

### Status

```bash
sudo fail2ban-client status sshd
```

---

### Functionality

- detects failed attempts
    
- blocks IPs automatically
    
- reduces the risk of brute-force attacks
    

---

## 🌐 Network Security (OCI)

### Exposed Ports

|Port|Status|Use|
|---|---|---|
|22|open|SSH|
|80|open|HTTP (Nginx)|
|8080|closed|backend (internal only)|
|5432|closed|database|

---

### OCI Rules

- public access only to necessary ports
    
- removal of temporary rules after testing
    
- manual control of exposure
    

---

## 🔒 Docker Containers

### Isolation

Each service runs in its own container:

```text
signus-proxy
signus-backend
signus-db
```

---

### Networks

- internal communication through the Docker network
    
- use of a controlled shared network
    
- no direct exposure of internal services
    

---

## 🔐 Backend

### Access

- not directly accessible from the Internet
    
- access only through the proxy
    

---

### Sensitive Variables

Defined in `.env`:

```text
JWT_SECRET
DB_PASSWORD
EMAIL_PASSWORD
```

---

### Applied Measures

- use of non-default values
    
- no hardcoding in source code
    
- configuration separation
    

---

## 🧪 Test Data

During phase 1:

- test credentials are used
    
- temporary JWT tokens are generated
    

⚠️ Do not use in real production

---

## ⚠️ Current Risks

### 1. Port 8080 exposed locally

Although not externally accessible, it is still published on the host.

---

### 2. Unconfigured variables

```text
EMAIL_*
FCM_SERVER_KEY
```

---

### 3. No HTTPS

- unencrypted traffic
    
- vulnerable to interception
    

---

## 🔮 Recommended Improvements

### 🔐 Access

- restrict SSH to a specific IP
    
- disable root login completely
    

---

### 🌐 Network

- remove exposure of port 8080
    
- add a firewall (`ufw`)
    

---

### 🔒 Backend

- rotation of `JWT_SECRET`
    
- secret management (vault / env manager)
    

---

### 🔑 HTTPS

- install Let's Encrypt certificates
    
- enforce HTTPS
    

---

### 📊 Monitoring

- centralized logs
    
- access alerts
    

---

## 📌 Applied Best Practices

- minimum necessary access
    
- service isolation
    
- use of environment variables
    
- network control
    
- SSH protection
    

---

## 🚀 Final State

System:

- reasonably secure for phase 1
    
- protected against basic attacks
    
- prepared for progressive hardening
    

---

## 🧠 Conclusion

A secure foundation has been built following production principles:

- access control
    
- minimal exposure
    
- separation of layers
    

The infrastructure is ready to evolve into a fully secure environment with HTTPS, managed secrets, and monitoring.

---
