#!/usr/bin/env bash
# Demo users — creation, login, and linking

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
