# Demo Automation — Status & Known Issues

## Current State

| Component | Branch | Status |
|-----------|--------|--------|
| signus_back | `feat/demo-optional-fcm` | ✅ Committed, compiles, Docker builds |
| signus_app | `feat/demo-mode` | ✅ Committed, APK builds (assembleDemo) |
| signus_infra | `feat/demo-script` | ⚠️ Committed, has active bug |

## What Works

- ✅ Prerequisites check (Java, SDK, Docker, AVDs)
- ✅ Backend detection and startup (reuses if running)
- ✅ User creation and login (idempotent: register→409→login)
- ✅ Linking verification (checks /me partnerId before creating)
- ✅ APK build (assembleDemo, correct BuildConfig)
- ✅ Emulator launch (nohup + disown to survive script exit)
- ✅ Serial detection by AVD (launch one at a time)

## Active Bug: grep regex in wait_for_boot

**File:** `demo/demo.sh`, `wait_for_boot()` function

**Problem:** `grep "$serial"` where serial is `emulator-5554` — the dash `-` is interpreted as a regex range operator, causing "Unmatched [" errors.

**Fix:** Change `grep "$serial"` to `grep -F "$serial"` (fixed-string match, not regex).

**Location in file:** Line ~415, inside Phase 1 of wait_for_boot:
```bash
# BROKEN:
state=$(adb devices 2>/dev/null | grep "$serial" | awk '{print $2}') || true

# FIX:
state=$(adb devices 2>/dev/null | grep -F "$serial" | awk '{print $2}') || true
```

## Fixed Issues (already committed)

1. **Emulator SIGHUP** — nohup + disown prevents process death
2. **curl -sf on 405** — use `-w "%{http_code}"` instead of `-f`
3. **stdout/stderr mixing** — print_ok/print_fail redirected to stderr
4. **Path detection** — search multiple candidates + env vars
5. **Nullable FcmConfig** — KoinModules null checks added
6. **Backend health check** — proper wait_for_port with timeout

## After Fixing grep Bug

Re-run the full demo:
```bash
./demo/demo.sh
```

Expected flow after fix:
1. Prerequisites → all green
2. Backend → reusing (already running)
3. Users → Alice/Bob logged in, already linked
4. APK → built
5. Emulators → User1_light starts, serial detected, boot waits...
6. **THIS IS WHERE IT FAILS NOW** — grep bug prevents boot detection
7. If boot detection works: User2_light starts, both boot
8. Install APK on both
9. Inject JWT via broadcast
10. Launch app on both
11. Summary printed

## Files Changed

### signus_back (`feat/demo-optional-fcm`)
- `src/main/kotlin/core/config/AppConfig.kt` — FcmConfig.serviceAccountJson: String?
- `src/main/kotlin/core/di/KoinModules.kt` — null-safe PushProvider binding

### signus_app (`feat/demo-mode`)
- `app/build.gradle.kts` — new "demo" buildType
- `app/src/main/java/.../data/local/TokenStore.kt` — restoreToken()
- `app/src/demo/java/.../DemoTokenReceiver.kt` — NEW broadcast receiver
- `app/src/demo/AndroidManifest.xml` — NEW receiver declaration with signature permission

### signus_infra (`feat/demo-script`)
- `demo/demo.sh` — main script (~580 lines)
- `demo/STATUS.md` — this file
- `README.md` — demo documentation added

## How to Resume

1. Fix the grep bug (one line change)
2. Run `./demo/demo.sh`
3. If new issues appear, check emulator logs: `cat /tmp/signus_demo/emu_User1_light.log`
4. Commit the fix
