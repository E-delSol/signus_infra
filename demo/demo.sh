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

# -- Source lib modules -------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    start_emulators
    wait_for_emulators
    install_and_launch
    print_summary
}

main "$@"
