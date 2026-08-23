#!/usr/bin/env bash
# Deploy — install APK, launch app, inject tokens

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

    # Restart app so SplashScreen re-evaluates navigation with the new token.
    # Without restart, the app stays on the Pairing screen because the
    # navigation was already decided before the token was injected.
    sleep 2
    print_step "Restarting apps to apply tokens..."

    adb -s "$SERIAL_A" shell am force-stop es.cronos.duo
    adb -s "$SERIAL_B" shell am force-stop es.cronos.duo
    sleep 1

    adb -s "$SERIAL_A" shell am start \
        -n es.cronos.duo/.MainActivity \
        --activity-clear-top 2>&1 | tail -1
    adb -s "$SERIAL_B" shell am start \
        -n es.cronos.duo/.MainActivity \
        --activity-clear-top 2>&1 | tail -1

    sleep 3
    print_ok "Demo ready — both devices authenticated"
}

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
