# 🖥️ Server Setup — Signus

## 📌 Objective

Prepare a secure Linux server ready to run production services using Docker containers.

---

## ☁️ Base Infrastructure

### Provider

- Oracle Cloud Free Tier
    

### Virtual Machine

- Ubuntu 24.04 LTS
    
- 4 CPUs
    
- 24 GB RAM
    
- 200 GB disk
    
- ARM architecture (`aarch64`)
    

---

## 🔐 Initial Security Configuration

### Operational User

The use of `root` is avoided for daily operations.

```bash
adduser ops
usermod -aG sudo ops
```

---

### SSH Access

#### Key-Based Authentication

Access is configured using a public key in:

```text
/home/ops/.ssh/authorized_keys
```

#### Disable Password Access

```bash
sudo nano /etc/ssh/sshd_config
```

```text
PasswordAuthentication no
```

Apply changes:

```bash
sudo systemctl restart ssh
```

---

## 🛡️ Protection Against Attacks

### Fail2Ban

Installation:

```bash
sudo apt install fail2ban
```

Enable:

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

Verification:

```bash
sudo fail2ban-client status sshd
```

---

## 🔄 System Update

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 📁 System Organization

A clear structure is defined for projects:

```text
/opt/projects/
└── signus/
    ├── backend/
    └── proxy/
```

---

## 📌 Applied Best Practices

- ❌ Do not use root
    
- ✅ SSH key-based access
    
- ❌ Disable SSH password authentication
    
- ✅ Fail2Ban active
    
- ✅ Clear directory structure
    

---

## 🚀 Final State

Server:

- accessible via secure SSH
    
- ready to run containers
    
- organized for multiple projects
    
- hardened against basic attacks
    

---
