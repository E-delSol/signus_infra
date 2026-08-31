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

# -- Source lib modules -------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -- Platform detection -------------------------------------------------------

source "$SCRIPT_DIR/lib/platform.sh"
detect_platform
detect_android_sdk

# -- Repository paths (set by setup_workspace) --------------------------------
# Defaults can be overridden via environment for non-standard layouts.
# INFRA_DIR defaults to the repo root where this script lives (the user
# already has signus_infra cloned — that's how they got this script).
# setup_workspace() clones the remaining repos into ./signus_demo/.

WORKSPACE="${DEMO_SIGNUS_DIR:-./signus_demo}"
INFRA_DIR="${SIGNUS_INFRA_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
APP_DIR="${SIGNUS_APP_DIR:-}"
BACKEND_DIR="${SIGNUS_BACKEND_DIR:-}"

# output.sh first (other modules depend on print_* functions)
source "$SCRIPT_DIR/lib/output.sh"

for f in "$SCRIPT_DIR"/lib/*.sh; do
    # Skip output.sh — already sourced
    [[ "$f" == */output.sh ]] && continue
    source "$f"
done

# -- Main ---------------------------------------------------------------------

main() {
    print_banner
    setup_workspace
    check_prerequisites
    start_backend
    prepare_demo_users
    build_apk

    # Emulator steps require Android SDK + emulator + AVDs
    local emulator_bin
    emulator_bin=$(platform_emulator_bin)
    if [ -n "$emulator_bin" ] && [ -n "${ANDROID_HOME:-}" ]; then
        start_emulators
        wait_for_emulators
        install_and_launch
        print_summary
    else
        print_section "Android emulators not available"
        echo "  The backend is running and the APK was built."
        echo "  To test on a device/emulator manually:"
        echo "    1. Install the APK from: $APK_PATH"
        echo "    2. Register two users and link them"
        echo "    3. Backend API: $API"
        echo ""
    fi
}

main "$@"
