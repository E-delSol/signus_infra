#!/usr/bin/env bash
# Build APK — Gradle assembleDemo with google-services.json dummy

build_apk() {
    print_section "Building demo APK"

    if [ ! -d "$APP_DIR" ]; then
        print_fail "App directory not found: $APP_DIR"
        exit 1
    fi

    # Ensure google-services.json exists (gitignored, needed by Gradle plugin)
    local gs_json="${APP_DIR}/app/google-services.json"
    if [ ! -f "$gs_json" ]; then
        print_warn "google-services.json not found — creating dummy for demo build"
        cat > "$gs_json" << 'DUMMY_GS'
{
  "project_info": {
    "project_number": "000000000000",
    "project_id": "signus-demo-placeholder",
    "storage_bucket": "signus-demo-placeholder.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:000000000000:android:0000000000000000",
        "android_client_info": {
          "package_name": "es.cronos.duo"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyDummyKeyForDemoOnly000000000"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
DUMMY_GS
    fi

    cd "$APP_DIR"

    # Discover the correct Gradle task
    print_step "Running Gradle assembleDemo..."
    if ./gradlew assembleDemo --quiet 2>&1 | tail -3; then
        print_ok "APK built"
    else
        print_fail "APK build failed"
        echo "    Check: cd $APP_DIR && ./gradlew assembleDemo"
        exit 1
    fi

    # Find the actual APK path
    APK_PATH=$(find app/build/outputs/apk/demo -name "*.apk" -type f 2>/dev/null | head -1)
    if [ -z "$APK_PATH" ]; then
        # Fallback: search broader
        APK_PATH=$(find app/build/outputs -name "*.apk" -path "*/demo/*" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$APK_PATH" ]; then
        print_fail "Could not find demo APK in build outputs"
        echo "    Looked in: app/build/outputs/apk/demo/"
        ls -la app/build/outputs/apk/ 2>/dev/null || true
        exit 1
    fi

    APK_PATH="$(cd "$(dirname "$APK_PATH")" && pwd)/$(basename "$APK_PATH")"
    print_ok "APK: $APK_PATH"
    cd - >/dev/null
}
