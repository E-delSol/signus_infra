#!/usr/bin/env bash
# Emulators — launch, detect serial, wait for boot

wait_for_boot() {
    local serial=$1 timeout=$2 start_time
    start_time=$(date +%s)

    # Phase 1: Wait for device to come online (state "device", not "offline")
    while true; do
        local state
        state=$(adb devices 2>/dev/null | grep -F "$serial" | awk '{print $2}') || true
        if [ "$state" = "device" ]; then
            break
        fi
        if [ $(($(date +%s) - start_time)) -ge "$timeout" ]; then
            return 1
        fi
        sleep 3
    done

    # Phase 2: Wait for sys.boot_completed = 1
    while true; do
        local boot_completed
        boot_completed=$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') || true
        if [ "$boot_completed" = "1" ]; then
            return 0
        fi
        if [ $(($(date +%s) - start_time)) -ge "$timeout" ]; then
            return 1
        fi
        sleep 3
    done
}

start_emulator_for_avd() {
    local avd=$1 label=$2
    local serial_before serial_after

    # Capture serials before launch
    serial_before=$(adb devices | grep -o 'emulator-[0-9]*' | sort)

    print_step "Starting emulator: $avd ($label)..." >&2
    platform_setsid "$ANDROID_HOME/emulator/emulator" -avd "$avd" -no-audio -gpu auto \
        > "${DEMO_DIR}/emu_${avd}.log" 2>&1 &

    # Wait for a new emulator serial to appear
    local start_time
    start_time=$(date +%s)
    while true; do
        sleep 2
        serial_after=$(adb devices | grep -o 'emulator-[0-9]*' | sort)
        local new_serial
        new_serial=$(comm -13 <(echo "$serial_before") <(echo "$serial_after") | head -1)
        if [ -n "$new_serial" ]; then
            print_ok "$label detected: $new_serial" >&2
            echo "$new_serial"
            return 0
        fi
        if [ $(($(date +%s) - start_time)) -ge 30 ]; then
            print_fail "Timeout waiting for $avd to appear in adb" >&2
            return 1
        fi
    done
}

start_emulators() {
    print_section "Starting Android emulators"

    SERIAL_A=$(start_emulator_for_avd "$AVD_A" "User A (Alice)")
    sleep 5  # Let first emulator settle before starting second
    SERIAL_B=$(start_emulator_for_avd "$AVD_B" "User B (Bob)")
}

wait_for_emulators() {
    print_section "Waiting for Android boot"

    print_step "Waiting for $SERIAL_A..."
    if wait_for_boot "$SERIAL_A" "$BOOT_TIMEOUT"; then
        print_ok "User A ready ($SERIAL_A)"
    else
        print_fail "User A boot timeout"
        exit 1
    fi

    print_step "Waiting for $SERIAL_B..."
    if wait_for_boot "$SERIAL_B" "$BOOT_TIMEOUT"; then
        print_ok "User B ready ($SERIAL_B)"
    else
        print_fail "User B boot timeout"
        exit 1
    fi
}
