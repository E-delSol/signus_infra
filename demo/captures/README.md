# Signus App - Screenshots Documentation

All screenshots captured from live Android emulators (Bob & Alice) running the Signus demo app.

## User Flow

```
Welcome → Login Options → Login Form → Pairing → QR Code → Semaphore
```

## Captures

| # | File | Screen | Description |
|---|------|--------|-------------|
| 01 | `01_welcome_fresh_install.png` | Welcome | First launch screen with "Comenzar" button |
| 02 | `02_login_options.png` | Login Options | "Usar correo electrónico" option (no Google on demo) |
| 03 | `03_login_form_empty.png` | Login Form | Empty email + password fields |
| 04 | `04_login_form_filled.png` | Login Form | Filled with alice@signus-demo.com |
| 05 | `05_pairing_screen_3_options.png` | Pairing | 3 pairing options: QR, Camera, Manual code |
| 06 | `06_qr_code_dialog.png` | QR Dialog | Generated QR code with expiration timer |
| 07 | `07_semaphore_busy.png` | Semaphore | "Estás Ocupado" state (red traffic light) |
| 08 | `08_semaphore_busy_partner_view.png` | Semaphore | Partner sees you as "Ocupado" with message |
| 09 | `09_semaphore_available.png` | Semaphore | "Estás Disponible" state (green traffic light) |
| 10 | `10_semaphore_available_partner_green.png` | Semaphore | Partner sees you as "Disponible" (green) |
| 11 | `11_settings.png` | Settings | "Desvincular pareja" + "Cerrar Sesión" options |
| 12 | `12_timer_picker_dialog.png` | Timer Dialog | Timer picker for timed status |
| 13 | `13_unlink_confirm_dialog.png` | Unlink Dialog | Confirmation before breaking pairing |
| 14 | `14_final_state_alice_busy.png` | Final State | Alice: Busy, sees Bob as partner |
| 15 | `15_final_state_bob_available.png` | Final State | Bob: Available, sees Alice as partner |

## Demo Credentials

| User | Email | Password |
|------|-------|----------|
| Alice | alice@signus-demo.com | demo1234 |
| Bob | bob@signus-demo.com | demo5678 |

## Re-capturing

To regenerate these screenshots:

```bash
cd signus_infra
./demo/demo.sh --yes
```

Then clear app data on both emulators, navigate through screens, and capture with:

```bash
adb -s emulator-5554 shell screencap -p /sdcard/captures/progress.png
adb -s emulator-5554 pull /sdcard/captures/progress.png <output_path>
```

## Notes

- Token injection requires app restart (force-stop + relaunch)
- Pairing screen only appears when no backend pairing exists
- QR codes expire after 5 minutes
- Backend must be running on localhost:8080
