# Screenshots

This directory will contain screenshots of the application.

To add screenshots:
1. Run the app on a device or emulator
2. Take screenshots of key features
3. Save them in this directory with descriptive names

Recommended screenshots:
- `main_screen.png` - Main configuration screen
- `battery_status.png` - Battery level display
- `monitoring_active.png` - Active monitoring status
- `slack_notification.png` - Example Slack notification

## Taking Screenshots

### Using Flutter DevTools
```bash
flutter screenshot
```

### Using Android Debug Bridge (ADB)
```bash
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

### Using Emulator
Use the camera button in the emulator toolbar.
