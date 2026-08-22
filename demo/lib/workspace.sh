#!/usr/bin/env bash
# Workspace setup — clones repos into ./signus_demo/

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
