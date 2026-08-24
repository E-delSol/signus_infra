#!/usr/bin/env bash
# Backend — Docker startup and health check

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
    if platform_port_in_use "$BACKEND_PORT"; then
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
