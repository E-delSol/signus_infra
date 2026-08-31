#!/usr/bin/env bash
# Workspace setup — clones repos into ./signus_demo/

setup_workspace() {
    print_section "Setting up workspace"

    local github_org="E-delSol"
    local app_branch="main"
    local back_branch="main"

    mkdir -p "$WORKSPACE"

    # signus_infra is already present — INFRA_DIR is set by demo.sh to the
    # repo root where this script lives, so no clone is needed here.

    # Clone signus_app if not present (and if not already set via env)
    if [ -z "$APP_DIR" ]; then
        APP_DIR="${WORKSPACE}/signus_app"
        if [ -d "$APP_DIR" ]; then
            print_ok "signus_app already present"
        else
            print_step "Cloning signus_app (${app_branch})..."
            if git clone --branch "$app_branch" --depth 1 \
                "https://github.com/${github_org}/signus_app.git" "$APP_DIR" 2>&1; then
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
                "https://github.com/${github_org}/signus_back.git" "$BACKEND_DIR" 2>&1; then
                print_ok "signus_back cloned"
            else
                print_fail "Failed to clone signus_back"
                exit 1
            fi
        fi
    fi

    print_ok "Workspace ready: $WORKSPACE"
}
