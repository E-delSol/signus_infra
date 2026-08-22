#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Signus Demo Launcher
#
# Creates two linked users (Alice & Bob) on emulators with the Signus app
# ready to test the semaphore (traffic light) feature.
#
# Usage: ./demo/demo.sh
# =============================================================================

# -- Configuration ------------------------------------------------------------

BACKEND_PORT=8080
API="http://localhost:${BACKEND_PORT}"
DEMO_DIR="/tmp/signus_demo"

USER_A_EMAIL="alice@signus-demo.com"
USER_A_PASS="demo1234"
USER_A_NAME="Alice"

USER_B_EMAIL="bob@signus-demo.com"
USER_B_PASS="demo5678"
USER_B_NAME="Bob"

AVD_A="User1_light"
AVD_B="User2_light"

BOOT_TIMEOUT=300

# -- Repository paths (set by setup_workspace) --------------------------------
# Defaults can be overridden via environment for non-standard layouts.
# When not set, setup_workspace() clones all repos into ./signus_demo/.

WORKSPACE="${DEMO_SIGNUS_DIR:-./signus_demo}"
INFRA_DIR="${SIGNUS_INFRA_DIR:-}"
APP_DIR="${SIGNUS_APP_DIR:-}"
BACKEND_DIR="${SIGNUS_BACKEND_DIR:-}"

# -- Output helpers -----------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_banner() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}         SIGNUS DEMO LAUNCHER${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_step() { echo -e "${BOLD}$1${NC}"; }
print_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_fail() { echo -e "  ${RED}✗${NC} $1"; }
print_section() { echo ""; echo -e "${BOLD}-- $1 --${NC}"; }

# -- Workspace setup -----------------------------------------------------------

setup_workspace() {
    print_section "Setting up workspace"

    local github_org="E-delSol"
    local infra_branch="feat/demo-script"
    local app_branch="feat/demo-mode"
    local back_branch="feat/demo-optional-fcm"

    mkdir -p "$WORKSPACE"

    # Clone signus_infra if not present (and if not already set via env)
    if [ -z "$INFRA_DIR" ]; then
        INFRA_DIR="${WORKSPACE}/signus_infra"
        if [ -d "$INFRA_DIR" ]; then
            print_ok "signus_infra already present"
        else
            print_step "Cloning signus_infra (${infra_branch})..."
            if git clone --branch "$infra_branch" --depth 1 \
                "git@github.com:${github_org}/signus_infra.git" "$INFRA_DIR" 2>&1; then
                print_ok "signus_infra cloned"
            else
                print_fail "Failed to clone signus_infra"
                echo "    Check SSH access to GitHub"
                exit 1
            fi
        fi
    fi

    # Clone signus_app if not present (and if not already set via env)
    if [ -z "$APP_DIR" ]; then
        APP_DIR="${WORKSPACE}/signus_app"
        if [ -d "$APP_DIR" ]; then
            print_ok "signus_app already present"
        else
            print_step "Cloning signus_app (${app_branch})..."
            if git clone --branch "$app_branch" --depth 1 \
                "git@github.com:${github_org}/signus_app.git" "$APP_DIR" 2>&1; then
                print_ok "signus_app cloned"
            else
                print_fail "Failed to clone signus_app"
                exit 1
            fi
        fi
    fi

    # Clone signus_back if not present (and if not already set via env)
    if [ -z "$BACKEND_DIR" ]; then
        BACKEND_DIR="${WORKSPACE}/signus_back"
        if [ -d "$BACKEND_DIR" ]; then
            print_ok "signus_back already present"
        else
            print_step "Cloning signus_back (${back_branch})..."
            if git clone --branch "$back_branch" --depth 1 \
                "git@github.com:${github_org}/signus_back.git" "$BACKEND_DIR" 2>&1; then
                print_ok "signus_back cloned"
            else
                print_fail "Failed to clone signus_back"
                exit 1
            fi
        fi
    fi

    print_ok "Workspace ready: $WORKSPACE"
}

# -- Prerequisites ------------------------------------------------------------

check_prerequisites() {
    print_section "Checking prerequisites"
    local failed=0

    if command -v java &>/dev/null && java -version &>/dev/null 2>&1; then
        print_ok "Java"
    else
        print_fail "Java not found"; failed=1
    fi

    if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
        print_ok "ANDROID_HOME ($ANDROID_HOME)"
    else
        print_fail "ANDROID_HOME not set"; failed=1
    fi

    if command -v adb &>/dev/null; then
        print_ok "adb"
    else
        print_fail "adb not found in PATH"; failed=1
    fi

    local emulator_bin="${ANDROID_HOME:-}/emulator/emulator"
    if [ -x "$emulator_bin" ] || command -v emulator &>/dev/null; then
        print_ok "emulator"
    else
        print_fail "emulator not found"; failed=1
    fi

    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        print_ok "Docker"
    else
        print_fail "Docker not running or not installed"; failed=1
    fi

    if docker compose version &>/dev/null 2>&1; then
        print_ok "Docker Compose"
    else
        print_fail "Docker Compose not available"; failed=1
    fi

    local avd_list
    avd_list=$("$ANDROID_HOME/emulator/emulator" -list-avds 2>/dev/null || true)

    if echo "$avd_list" | grep -qx "$AVD_A"; then
        print_ok "AVD $AVD_A"
    else
        print_fail "AVD $AVD_A not found"; failed=1
    fi

    if echo "$avd_list" | grep -qx "$AVD_B"; then
        print_ok "AVD $AVD_B"
    else
        print_fail "AVD $AVD_B not found"; failed=1
    fi

    if [ $failed -ne 0 ]; then
        echo ""
        echo -e "${RED}Prerequisites failed. Fix the issues above and try again.${NC}"
        exit 1
    fi
}

# -- Backend ------------------------------------------------------------------

wait_for_port() {
    local port=$1 timeout=$2 start_time
    start_time=$(date +%s)
    while true; do
        # Use curl without -f to accept any HTTP response (backend is alive)
        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${port}/auth/login" 2>/dev/null) || true
        if [ -n "$http_code" ] && [ "$http_code" != "000" ]; then
            return 0
        fi
        if [ $(($(date +%s) - start_time)) -ge "$timeout" ]; then return 1; fi
        sleep 2
    done
}

start_backend() {
    print_section "Starting backend"

    # Check if backend is already available (any HTTP response means it's alive)
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "${API}/auth/login" 2>/dev/null) || true
    if [ -n "$http_code" ] && [ "$http_code" != "000" ]; then
        print_ok "Backend already running on port ${BACKEND_PORT}, reusing"
        return 0
    fi

    # Check if port is occupied by something else
    if command -v lsof &>/dev/null && lsof -i ":${BACKEND_PORT}" &>/dev/null 2>&1; then
        print_warn "Port ${BACKEND_PORT} occupied by another process"
        echo "    Stop it manually or change BACKEND_PORT in this script"
        exit 1
    fi

    print_step "Building and starting Docker containers..."

    # Ensure secrets directory and dummy service account exist
    local secrets_dir="${BACKEND_DIR}/secrets"
    mkdir -p "$secrets_dir"
    if [ ! -f "$secrets_dir/service-account.json" ]; then
        cat > "$secrets_dir/service-account.json" << 'DUMMY_SA'
{
  "type": "service_account",
  "project_id": "signus-demo-placeholder",
  "private_key_id": "demo-key-id",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA\nDUMMY_KEY_FOR_DEMO_ONLY\n-----END RSA PRIVATE KEY-----\n",
  "client_email": "signus-demo@placeholder.iam.gserviceaccount.com",
  "client_id": "000000000000",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/signus-demo%40placeholder.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
DUMMY_SA
        print_warn "Created dummy Firebase service account (FCM disabled, WebSocket works)"
    fi

    # Ensure .env exists
    if [ ! -f "${BACKEND_DIR}/.env" ]; then
        if [ -f "${BACKEND_DIR}/.env.example" ]; then
            cp "${BACKEND_DIR}/.env.example" "${BACKEND_DIR}/.env"
            print_warn "Created .env from .env.example"
        else
            print_fail "No .env or .env.example in backend repo"
            exit 1
        fi
    fi

    cd "$BACKEND_DIR"
    docker compose up -d --build 2>&1 | tail -5
    cd - >/dev/null

    print_step "Waiting for PostgreSQL and Ktor..."
    if ! wait_for_port "$BACKEND_PORT" 120; then
        print_fail "Backend failed to start within 120 seconds"
        echo "    Check: cd $BACKEND_DIR && docker compose logs"
        exit 1
    fi

    print_ok "Backend running on port ${BACKEND_PORT}"
}

# -- Demo users ---------------------------------------------------------------

create_or_login_user() {
    local email=$1 password=$2 name=$3 label=$4
    local response token

    # Try register first
    response=$(curl -sf -X POST "${API}/auth/register" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"${email}\",\"password\":\"${password}\",\"displayName\":\"${name}\"}" 2>/dev/null) || true

    if [ -n "$response" ]; then
        token=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])" 2>/dev/null) || true
        if [ -n "$token" ]; then
            print_ok "${label} created" >&2
            echo "$token"
            return 0
        fi
    fi

    # Try login (user might already exist)
    response=$(curl -sf -X POST "${API}/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"${email}\",\"password\":\"${password}\"}" 2>/dev/null) || true

    if [ -n "$response" ]; then
        token=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])" 2>/dev/null) || true
        if [ -n "$token" ]; then
            print_ok "${label} logged in (already existed)" >&2
            echo "$token"
            return 0
        fi
    fi

    print_fail "Failed to create or login ${label}" >&2
    return 1
}

verify_or_create_linking() {
    local me_response partner_id

    # Check if already linked via /me
    me_response=$(curl -sf -H "Authorization: Bearer ${TOKEN_A}" "${API}/me" 2>/dev/null) || true

    if [ -n "$me_response" ]; then
        partner_id=$(echo "$me_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('partnerId') or '')" 2>/dev/null) || true
        if [ -n "$partner_id" ]; then
            print_ok "Alice <-> Bob already linked"
            return 0
        fi
    fi

    # Not linked -- create linking session and confirm
    print_step "Linking Alice <-> Bob..."

    local session_response link_code
    session_response=$(curl -sf -X POST "${API}/linking/sessions" \
        -H "Authorization: Bearer ${TOKEN_A}" \
        -H "Content-Type: application/json" 2>/dev/null) || true

    if [ -z "$session_response" ]; then
        print_fail "Failed to create linking session"
        return 1
    fi

    link_code=$(echo "$session_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['linkCode'])" 2>/dev/null) || true

    if [ -z "$link_code" ]; then
        print_fail "Failed to extract link code"
        return 1
    fi

    # Confirm with User B
    local confirm_response
    confirm_response=$(curl -sf -X POST "${API}/linking/sessions/confirm" \
        -H "Authorization: Bearer ${TOKEN_B}" \
        -H "Content-Type: application/json" \
        -d "{\"linkCode\":\"${link_code}\"}" 2>/dev/null) || true

    if [ -z "$confirm_response" ]; then
        # Might be 409 (already linked) -- verify
        me_response=$(curl -sf -H "Authorization: Bearer ${TOKEN_A}" "${API}/me" 2>/dev/null) || true
        partner_id=$(echo "$me_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('partnerId') or '')" 2>/dev/null) || true
        if [ -n "$partner_id" ]; then
            print_ok "Alice <-> Bob already linked"
            return 0
        fi
        print_fail "Failed to confirm linking session"
        return 1
    fi

    print_ok "Alice <-> Bob linked"
}

prepare_demo_users() {
    print_section "Preparing demo users"
    mkdir -p "$DEMO_DIR"

    TOKEN_A=$(create_or_login_user "$USER_A_EMAIL" "$USER_A_PASS" "$USER_A_NAME" "Alice")
    echo "$TOKEN_A" > "${DEMO_DIR}/token_a"

    TOKEN_B=$(create_or_login_user "$USER_B_EMAIL" "$USER_B_PASS" "$USER_B_NAME" "Bob")
    echo "$TOKEN_B" > "${DEMO_DIR}/token_b"

    verify_or_create_linking
}

# -- Build APK ----------------------------------------------------------------

build_apk() {
    print_section "Building demo APK"

    if [ ! -d "$APP_DIR" ]; then
        print_fail "App directory not found: $APP_DIR"
        exit 1
    fi

    # Ensure google-services.json exists (gitignored, needed by Gradle plugin)
    local gs_json="${APP_DIR}/app/google-services.json"
    if [ ! -f "$gs_json" ]; then
        print_warn "google-services.json not found — creating dummy for demo build"
        cat > "$gs_json" << 'DUMMY_GS'
{
  "project_info": {
    "project_number": "000000000000",
    "project_id": "signus-demo-placeholder",
    "storage_bucket": "signus-demo-placeholder.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:000000000000:android:0000000000000000",
        "android_client_info": {
          "package_name": "es.cronos.duo"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyDummyKeyForDemoOnly000000000"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
DUMMY_GS
    fi

    cd "$APP_DIR"

    # Discover the correct Gradle task
    print_step "Running Gradle assembleDemo..."
    if ./gradlew assembleDemo --quiet 2>&1 | tail -3; then
        print_ok "APK built"
    else
        print_fail "APK build failed"
        echo "    Check: cd $APP_DIR && ./gradlew assembleDemo"
        exit 1
    fi

    # Find the actual APK path
    APK_PATH=$(find app/build/outputs/apk/demo -name "*.apk" -type f 2>/dev/null | head -1)
    if [ -z "$APK_PATH" ]; then
        # Fallback: search broader
        APK_PATH=$(find app/build/outputs -name "*.apk" -path "*/demo/*" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$APK_PATH" ]; then
        print_fail "Could not find demo APK in build outputs"
        echo "    Looked in: app/build/outputs/apk/demo/"
        ls -la app/build/outputs/apk/ 2>/dev/null || true
        exit 1
    fi

    APK_PATH="$(cd "$(dirname "$APK_PATH")" && pwd)/$(basename "$APK_PATH")"
    print_ok "APK: $APK_PATH"
    cd - >/dev/null
}

# -- Emulators ----------------------------------------------------------------

wait_for_boot() {
    local serial=$1 timeout=$2 start_time
    start_time=$(date +%s)

    # Phase 1: Wait for device to come online (state "device", not "offline")
    while true; do
        local state
        state=$(adb devices 2>/dev/null | grep -F "$serial" | awk '{print $2}') || true
        if [ "$state" = "device" ]; then
            break
        fi
        if [ $(($(date +%s) - start_time)) -ge "$timeout" ]; then
            return 1
        fi
        sleep 3
    done

    # Phase 2: Wait for sys.boot_completed = 1
    while true; do
        local boot_completed
        boot_completed=$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') || true
        if [ "$boot_completed" = "1" ]; then
            return 0
        fi
        if [ $(($(date +%s) - start_time)) -ge "$timeout" ]; then
            return 1
        fi
        sleep 3
    done
}

start_emulator_for_avd() {
    local avd=$1 label=$2
    local serial_before serial_after

    # Capture serials before launch
    serial_before=$(adb devices | grep -o 'emulator-[0-9]*' | sort)

    print_step "Starting emulator: $avd ($label)..." >&2
    setsid "$ANDROID_HOME/emulator/emulator" -avd "$avd" -no-audio -gpu auto \
        > "${DEMO_DIR}/emu_${avd}.log" 2>&1 &

    # Wait for a new emulator serial to appear
    local start_time
    start_time=$(date +%s)
    while true; do
        sleep 2
        serial_after=$(adb devices | grep -o 'emulator-[0-9]*' | sort)
        local new_serial
        new_serial=$(comm -13 <(echo "$serial_before") <(echo "$serial_after") | head -1)
        if [ -n "$new_serial" ]; then
            print_ok "$label detected: $new_serial" >&2
            echo "$new_serial"
            return 0
        fi
        if [ $(($(date +%s) - start_time)) -ge 30 ]; then
            print_fail "Timeout waiting for $avd to appear in adb" >&2
            return 1
        fi
    done
}

start_emulators() {
    print_section "Starting Android emulators"

    SERIAL_A=$(start_emulator_for_avd "$AVD_A" "User A (Alice)")
    sleep 5  # Let first emulator settle before starting second
    SERIAL_B=$(start_emulator_for_avd "$AVD_B" "User B (Bob)")
}

wait_for_emulators() {
    print_section "Waiting for Android boot"

    print_step "Waiting for $SERIAL_A..."
    if wait_for_boot "$SERIAL_A" "$BOOT_TIMEOUT"; then
        print_ok "User A ready ($SERIAL_A)"
    else
        print_fail "User A boot timeout"
        exit 1
    fi

    print_step "Waiting for $SERIAL_B..."
    if wait_for_boot "$SERIAL_B" "$BOOT_TIMEOUT"; then
        print_ok "User B ready ($SERIAL_B)"
    else
        print_fail "User B boot timeout"
        exit 1
    fi
}

# -- Install and launch -------------------------------------------------------

install_and_launch() {
    print_section "Installing APK and injecting tokens"

    # Install on both emulators
    print_step "Installing APK on User A..."
    adb -s "$SERIAL_A" install -r "$APK_PATH" 2>&1 | tail -1
    print_ok "Installed on User A"

    print_step "Installing APK on User B..."
    adb -s "$SERIAL_B" install -r "$APK_PATH" 2>&1 | tail -1
    print_ok "Installed on User B"

    # Launch app FIRST so DemoTokenReceiver is alive to receive the broadcast.
    # On Android 12+, broadcasts to stopped apps require explicit component targeting,
    # but it's simpler and more reliable to just launch first.
    print_step "Launching Signus on both devices..."

    adb -s "$SERIAL_A" shell am start \
        -n es.cronos.duo/.MainActivity \
        --activity-clear-top 2>&1 | tail -1

    adb -s "$SERIAL_B" shell am start \
        -n es.cronos.duo/.MainActivity \
        --activity-clear-top 2>&1 | tail -1

    sleep 3  # Let app fully start so Koin + DemoTokenReceiver are ready
    print_ok "Signus launched on both devices"

    # Inject JWT tokens via broadcast (explicit component required by Android 12+)
    print_step "Injecting demo tokens..."

    local token_a token_b
    token_a=$(cat "${DEMO_DIR}/token_a")
    token_b=$(cat "${DEMO_DIR}/token_b")

    adb -s "$SERIAL_A" shell am broadcast \
        -n es.cronos.duo/.DemoTokenReceiver \
        -a es.cronos.duo.ACTION_INJECT_DEMO_TOKEN \
        --es token "$token_a" 2>&1 | tail -1
    print_ok "Token injected for Alice"

    adb -s "$SERIAL_B" shell am broadcast \
        -n es.cronos.duo/.DemoTokenReceiver \
        -a es.cronos.duo.ACTION_INJECT_DEMO_TOKEN \
        --es token "$token_b" 2>&1 | tail -1
    print_ok "Token injected for Bob"

    sleep 2
    print_ok "Demo ready — both devices authenticated"
}

# -- Summary ------------------------------------------------------------------

print_summary() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}         SIGNUS DEMO READY${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "  ${BOLD}User A:${NC} Alice  (${USER_A_EMAIL})"
    echo -e "  ${BOLD}User B:${NC} Bob    (${USER_B_EMAIL})"
    echo ""
    echo -e "  ${BOLD}Emulator A:${NC} $SERIAL_A  (AVD: $AVD_A)"
    echo -e "  ${BOLD}Emulator B:${NC} $SERIAL_B  (AVD: $AVD_B)"
    echo ""
    echo -e "  ${BOLD}Backend:${NC}   http://localhost:${BACKEND_PORT}"
    echo ""
    echo "  Both users are linked. Try changing the semaphore"
    echo "  state on either device and watch the other update."
    echo ""
}

# -- Main ---------------------------------------------------------------------

main() {
    print_banner
    setup_workspace
    check_prerequisites
    start_backend
    prepare_demo_users
    build_apk
    start_emulators
    wait_for_emulators
    install_and_launch
    print_summary
}

main "$@"
