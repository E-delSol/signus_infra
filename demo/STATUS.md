# Demo Automation — Status & Known Issues

## Current State

All demo code lives on **`main`** across every repository.

| Component | Branch | Status |
|-----------|--------|--------|
| signus_back | `main` | ✅ Committed, compiles, Docker builds |
| signus_app | `main` | ✅ Committed, APK builds (assembleDemo) |
| signus_infra | `main` | ✅ Committed, tested end-to-end |

## ✅ End-to-End Verified (21 Aug 2026)

Full flow tested manually on physical emulators:
1. ✅ Prerequisites check (Java, SDK, Docker, AVDs)
2. ✅ Backend detection and startup (reuses if running)
3. ✅ User creation and login (idempotent: register→409→login)
4. ✅ Linking verification (checks /me partnerId before creating)
5. ✅ APK build (assembleDemo, correct BuildConfig)
6. ✅ Emulator launch with **setsid** (fully detached from parent shell)
7. ✅ Serial detection by AVD (launch one at a time, diff serials)
8. ✅ Boot detection (wait_for_boot with `grep -F` for fixed-string match)
9. ✅ APK install on both emulators
10. ✅ App launch (must launch BEFORE broadcast injection)
11. ✅ JWT injection via **explicit component** (`-n .DemoTokenReceiver`)
12. ✅ WebSocket connected, receiving real-time updates

## Fixed Issues (all committed)

1. **Emulator process death** — `setsid` instead of `nohup`+`disown` (new session)
2. **Signature permission blocks adb** — removed from manifest; demo source-set isolation suffices
3. **Broadcast needs explicit component** — Android 12+ requires `-n` for implicit broadcasts to stopped apps
4. **Launch before inject** — app must be running so Koin + DemoTokenReceiver are alive
5. **curl -sf on 405** — use `-w "%{http_code}"` instead of `-f`
6. **stdout/stderr mixing** — print_ok/print_fail redirected to stderr
7. **Path detection** — search multiple candidates + env vars
8. **grep regex error** — `grep -F` for fixed-string match on `emulator-5554`
9. **Nullable FcmConfig** — KoinModules null checks added

## Files Changed

### signus_back
- `src/main/kotlin/core/config/AppConfig.kt` — FcmConfig.serviceAccountJson: String?
- `src/main/kotlin/core/di/KoinModules.kt` — null-safe PushProvider binding

### signus_app
- `app/build.gradle.kts` — new "demo" buildType (BASE_URL=10.0.2.2:8080)
- `app/src/main/java/.../data/local/TokenStore.kt` — restoreToken()
- `app/src/demo/java/.../DemoTokenReceiver.kt` — broadcast receiver (no signature permission)
- `app/src/demo/AndroidManifest.xml` — receiver declaration (exported, no permission)

### signus_infra
- `demo/demo.sh` — main script, auto-detects INFRA_DIR from repo root
- `demo/lib/workspace.sh` — workspace setup (clones app + backend from main)
- `demo/STATUS.md` — this file
- `README.md` — demo documentation

## How to Run

```bash
./demo/demo.sh
```

Both emulators will boot (~30s each), APK installs, tokens injected, app opens authenticated.

## Emulator Tips

- Emulators must be **visible** (no `-no-window`)
- `-no-audio` is fine, `-gpu auto` recommended
- Logs at `/tmp/signus_demo/emu_User1_light.log`
- Kill emulator: `adb -s emulator-5554 emu kill`
