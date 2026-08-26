#!/usr/bin/env bash
# Prerequisites check — validates required tools and resources
#
# Fatal:      Java, Docker, Docker Compose
# Non-fatal:  Android SDK, adb, emulator, AVDs (warns and continues)

check_prerequisites() {
    print_section "Checking prerequisites"
    local failed=0
    local warnings=0

    # ── Java (FATAL) ──────────────────────────────────────────────────────
    if command -v java &>/dev/null && java -version &>/dev/null 2>&1; then
        print_ok "Java"
    else
        print_fail "Java not found"
        echo "  → See README.md#javajdk-17+ for installation instructions"
        failed=1
    fi

    # ── Android SDK (NON-FATAL) ──────────────────────────────────────────
    if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
        print_ok "ANDROID_HOME ($ANDROID_HOME)"
    else
        print_warn "ANDROID_HOME not set"
        echo "  → See README.md#android-sdk-optional for installation instructions"
        echo "  → The demo will continue without Android emulators."
        warnings=$((warnings + 1))
    fi

    # ── adb (NON-FATAL) ──────────────────────────────────────────────────
    if command -v adb &>/dev/null; then
        print_ok "adb"
    elif [ -n "${ANDROID_HOME:-}" ] && [ -x "$ANDROID_HOME/platform-tools/adb" ]; then
        print_ok "adb ($ANDROID_HOME/platform-tools/adb)"
    else
        print_warn "adb not found in PATH"
        echo "  → See README.md#android-sdk-optional for installation instructions"
        warnings=$((warnings + 1))
    fi

    # ── Emulator (NON-FATAL) ─────────────────────────────────────────────
    local emulator_bin
    emulator_bin=$(platform_emulator_bin)
    if [ -n "$emulator_bin" ]; then
        print_ok "emulator ($emulator_bin)"
    else
        print_warn "emulator not found"
        echo "  → See README.md#android-sdk-optional for installation instructions"
        warnings=$((warnings + 1))
    fi

    # ── AVDs (NON-FATAL) ─────────────────────────────────────────────────
    if [ -n "$emulator_bin" ]; then
        local avd_list
        avd_list=$("$emulator_bin" -list-avds 2>/dev/null || true)

        if echo "$avd_list" | grep -qx "$AVD_A"; then
            print_ok "AVD $AVD_A"
        else
            print_warn "AVD $AVD_A not found"
            echo "  → See README.md#avds-optional for creation instructions"
            warnings=$((warnings + 1))
        fi

        if echo "$avd_list" | grep -qx "$AVD_B"; then
            print_ok "AVD $AVD_B"
        else
            print_warn "AVD $AVD_B not found"
            echo "  → See README.md#avds-optional for creation instructions"
            warnings=$((warnings + 1))
        fi
    fi

    # ── Docker (FATAL) ───────────────────────────────────────────────────
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        print_ok "Docker"
    else
        print_fail "Docker not running or not installed"
        echo "  → See README.md#docker for installation instructions"
        echo "  → Make sure Docker Desktop is running before retrying."
        failed=1
    fi

    # ── Docker Compose (FATAL) ───────────────────────────────────────────
    if docker compose version &>/dev/null 2>&1; then
        print_ok "Docker Compose"
    else
        print_fail "Docker Compose not available"
        echo "  → See README.md#docker for installation instructions (Docker Compose is included with Docker Desktop)."
        failed=1
    fi

    # ── Summary ──────────────────────────────────────────────────────────
    if [ $failed -ne 0 ]; then
        echo ""
        echo -e "${RED}Prerequisites failed. Fix the issues above and try again.${NC}"
        exit 1
    fi

    if [ $warnings -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Some Android tools are missing. The backend will work, but emulators won't launch.${NC}"
        echo -e "${YELLOW}You can still test the backend API and build the APK.${NC}"
        echo ""
    fi
}
