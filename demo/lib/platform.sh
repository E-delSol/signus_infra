#!/usr/bin/env bash
# Platform detection and cross-platform wrappers
#
# Provides wrapper functions so demo.sh works on Linux, macOS, and
# Windows (Git Bash) without modifying the core logic of each module.

# -- Detection ----------------------------------------------------------------

detect_platform() {
    case "$(uname -s)" in
        Linux*)                  PLATFORM="linux";;
        Darwin*)                 PLATFORM="macos";;
        MINGW*|MSYS*|CYGWIN*)   PLATFORM="windows";;
        *)                       PLATFORM="unknown";;
    esac
    export PLATFORM
}

# -- Wrappers -----------------------------------------------------------------

# Launch a process in a new session (detached from parent shell).
# Linux:   setsid (native)
# macOS:   nohup (setsid not available)
# Windows: simple background (Git Bash doesn't support setsid)
platform_setsid() {
    case "$PLATFORM" in
        linux)   setsid "$@" ;;
        macos)   nohup "$@" > /dev/null 2>&1 & ;;
        windows) "$@" & ;;
        *)       "$@" & ;;
    esac
}

# Check if a TCP port is already in use.
# Tries lsof → ss → netstat (covers Linux, macOS, Git Bash).
platform_port_in_use() {
    local port=$1
    if command -v lsof &>/dev/null; then
        lsof -i ":${port}" &>/dev/null 2>&1
    elif command -v ss &>/dev/null; then
        ss -tlnp | grep -q ":${port} "
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | grep -q ":${port} "
    else
        return 1
    fi
}

# Extract a top-level field from a JSON string.
# Tries jq → python3 → python (covers all platforms).
platform_json_field() {
    local json=$1 field=$2
    if command -v jq &>/dev/null; then
        echo "$json" | jq -r ".$field"
    elif command -v python3 &>/dev/null; then
        echo "$json" | python3 -c "import sys,json; print(json.load(sys.stdin)['$field'])"
    elif command -v python &>/dev/null; then
        echo "$json" | python -c "import sys,json; print(json.load(sys.stdin)['$field'])"
    else
        echo ""
        return 1
    fi
}

# Extract a field that may be null (returns empty string instead of "None").
# Uses python get() for safe access.
platform_json_field_nullable() {
    local json=$1 field=$2
    if command -v jq &>/dev/null; then
        echo "$json" | jq -r ".$field // empty"
    elif command -v python3 &>/dev/null; then
        echo "$json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field') or '')"
    elif command -v python &>/dev/null; then
        echo "$json" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field') or '')"
    else
        echo ""
        return 1
    fi
}

# Run Gradle wrapper with the correct binary per platform.
# Windows: gradlew.bat via cmd.exe
# Linux/macOS: ./gradlew
platform_gradlew() {
    if [ "$PLATFORM" = "windows" ]; then
        cmd.exe //c "gradlew.bat $*" 2>&1
    else
        ./"gradlew" "$@" 2>&1
    fi
}
