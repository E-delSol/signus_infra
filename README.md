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

## 🌐 Part of the Signus Ecosystem

Signus is structured as a multi-repository system:

- [signus_app](https://github.com/E-delSol/signus_app) — Android client
    
- [signus_back](https://github.com/E-delSol/signus_back) — Backend API (Ktor + WebSockets)
    
- **signus_infra** — Infrastructure, deployment, and technical documentation (this repository)
- [signus_landing](https://github.com/E-delSol/signus_landing) — Landing page
    
🌐 **Live:** [e-delsol.github.io/signus_landing](https://e-delsol.github.io/signus_landing/)
    

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

## 🚀 Demo Launcher

One-command demo that sets up Signus with two linked users on Android emulators.

### Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Linux | ✅ Tested | Full support |
| macOS | ⚠️ Not tested | Should work (bash + Android SDK). Report any issues. |
| Windows | ⚠️ Not tested | Use `.\demo\demo.ps1` (Git for Windows required). Report any issues. |

### Prerequisites

The demo requires these tools. Install anything that's missing before running.

| Tool | Required | Purpose |
|------|----------|---------|
| Java/JDK 17+ | ✅ Fatal | Backend compilation |
| Docker | ✅ Fatal | Backend services (PostgreSQL + Ktor) |
| Docker Compose | ✅ Fatal | Service orchestration |
| Android SDK | ⚠️ Optional | Emulator support (backend works without it) |
| adb | ⚠️ Optional | Device communication |
| emulator | ⚠️ Optional | Virtual Android devices |
| AVDs | ⚠️ Optional | Pre-configured virtual devices |
| jq or Python 3 | ⚠️ Optional | JSON parsing in scripts |

> **Fatal** = demo won't start without it. **Optional** = backend works, emulators won't launch.

#### Java/JDK 17+

**Verify:**

```bash
java -version
```

Should show `17` or higher.

<details>
<summary>Linux (Ubuntu/Debian)</summary>

```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

</details>

<details>
<summary>Linux (Fedora/RHEL)</summary>

```bash
sudo dnf install java-17-openjdk-devel
```

</details>

<details>
<summary>macOS</summary>

```bash
brew install openjdk@17
```

If you don't have Homebrew: https://brew.sh

</details>

<details>
<summary>Windows</summary>

```powershell
winget install Microsoft.OpenJDK.17
```

Or download from https://adoptium.net

</details>

#### Docker

**Verify:**

```bash
docker --version
docker compose version
```

<details>
<summary>Linux</summary>

Follow the official guide for your distro:

- Ubuntu/Debian: https://docs.docker.com/engine/install/ubuntu/
- Fedora: https://docs.docker.com/engine/install/fedora/

Quick version (Ubuntu):

```bash
# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Run without sudo (optional but recommended)
sudo usermod -aG docker $USER
newgrp docker
```

</details>

<details>
<summary>macOS</summary>

```bash
brew install --cask docker
```

Or download Docker Desktop: https://docs.docker.com/desktop/install/mac-install/

</details>

<details>
<summary>Windows</summary>

Download Docker Desktop: https://docs.docker.com/desktop/install/windows-install/

Requires WSL 2 or Hyper-V enabled.

</details>

#### Android SDK (Optional)

Only needed if you want emulators. The backend API works without it.

**Verify:**

```bash
echo $ANDROID_HOME
adb --version
```

**Install:**

1. Download Android Studio: https://developer.android.com/studio
2. Run the installer and select "Standard" setup
3. Open Android Studio → SDK Manager → install the latest SDK

**Set ANDROID_HOME:**

<details>
<summary>Linux</summary>

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

</details>

<details>
<summary>macOS</summary>

Add to `~/.zshrc` (or `~/.bashrc`):

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

</details>

<details>
<summary>Windows</summary>

```powershell
setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk"
```

Then add `%ANDROID_HOME%\platform-tools` and `%ANDROID_HOME%\emulator` to your PATH.

</details>

#### AVDs (Optional)

If emulators are available but the required AVDs are missing:

```bash
$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    -n User1_light -k "system-images;android-33;google_apis;x86_64" \
    -d "pixel_4"

$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    -n User2_light -k "system-images;android-33;google_apis;x86_64" \
    -d "pixel_4"
```

#### jq or Python 3 (Optional)

Used for JSON parsing in demo scripts. `jq` is preferred.

```bash
# Linux
sudo apt install jq

# macOS
brew install jq

# Windows (Git Bash)
winget install jqlang.jq
```

If neither is available, the script will fall back to Python 3.

### Running the demo

Clone the repository and run the demo script:

**Linux / macOS:**
```bash
git clone https://github.com/E-delSol/signus_infra.git
cd signus_infra
./demo/demo.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/E-delSol/signus_infra.git
cd signus_infra
& "C:\Program Files\Git\bin\bash.exe" ".\demo\demo.sh"
```

> **Tip:** If you have SSH keys configured, you can use `git@github.com:E-delSol/signus_infra.git` instead.

#### Windows Setup

1. Install [Git for Windows](https://git-scm.com/download/win)
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
3. Install Android SDK and set `ANDROID_HOME` environment variable
4. Run: `.\demo\demo.ps1`

#### macOS Setup

1. Install Xcode Command Line Tools: `xcode-select --install`
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
3. Install Android SDK (via Android Studio or command-line tools)
4. Run: `./demo/demo.sh`

> **Note:** macOS has not been physically tested. The script should work
> based on bash compatibility, but report any issues.

This will:
1. Check all prerequisites
2. Start the backend (PostgreSQL + Ktor) in Docker
3. Create two users (Alice & Bob) and link them
4. Build the demo APK
5. Launch two visible emulators
6. Install the app and inject authentication tokens
7. Open Signus on both devices ready to use

### Demo Users

| User | Email | Password |
|------|-------|----------|
| Alice | alice@signus-demo.com | demo1234 |
| Bob | bob@signus-demo.com | demo5678 |

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

### Screenshots

Captured screenshots of all app screens are available in [`demo/captures/`](demo/captures/).

See [captures/README.md](demo/captures/README.md) for the full index.

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
