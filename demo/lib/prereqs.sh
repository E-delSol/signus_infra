#!/usr/bin/env bash
# Prerequisites check — validates all required tools and resources

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
        print_fail "Docker running or not installed"; failed=1
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
