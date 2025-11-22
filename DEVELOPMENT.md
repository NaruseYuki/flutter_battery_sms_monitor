# Development Guide

## Architecture

The app follows a service-based architecture:

### Core Components

1. **Services** (`lib/services/`)
   - `battery_monitor_service.dart`: Handles battery monitoring and alarm scheduling
   - `sms_monitor_service.dart`: Handles SMS reading and forwarding

2. **API Client** (`lib/api/`)
   - `slack_api.dart`: Retrofit-based API client for Slack webhook communication
   - `slack_api.g.dart`: Auto-generated code (created by build_runner)

3. **Screens** (`lib/screens/`)
   - `home_screen.dart`: Main UI for configuration and monitoring status

4. **Main** (`lib/main.dart`)
   - App entry point
   - Initializes Android Alarm Manager

## Key Features Implementation

### Battery Monitoring

1. User sets monitoring time and threshold via UI
2. Settings saved to SharedPreferences
3. Android Alarm Manager schedules daily alarm
4. At scheduled time, `batteryCheckCallback` is triggered
5. Battery level is checked using battery_plus
6. If level ≤ threshold, alert sent to Slack via Retrofit

### SMS Monitoring

1. SmsReceiver listens for incoming SMS
2. When SMS received, `_handleSmsReceived` is called
3. Message details formatted and sent to Slack via Retrofit
4. Uses same webhook URL as battery monitoring

## Data Flow

```
User Input (UI) 
    ↓
SharedPreferences (Settings Storage)
    ↓
Services (Battery/SMS)
    ↓
Retrofit API Client
    ↓
Slack Webhook
```

## Code Generation

The app uses build_runner for code generation:

- **Retrofit**: Generates HTTP client implementation
- **JSON Serialization**: Generates toJson/fromJson methods

Files that trigger code generation (with `part` directive):
- `lib/api/slack_api.dart` → generates `slack_api.g.dart`

## Permissions

Required Android permissions (AndroidManifest.xml):
- `READ_SMS`: Read SMS messages
- `RECEIVE_SMS`: Receive incoming SMS
- `RECEIVE_BOOT_COMPLETED`: Restart alarms after reboot
- `WAKE_LOCK`: Wake device for alarm
- `SCHEDULE_EXACT_ALARM`: Schedule exact time alarms
- `INTERNET`: Send data to Slack

## Dependencies Explained

- **battery_plus**: Cross-platform battery level monitoring
- **android_alarm_manager_plus**: Reliable background task scheduling
- **sms_advanced**: SMS reading on Android
- **dio**: HTTP client (required by Retrofit)
- **retrofit**: Type-safe REST client
- **permission_handler**: Runtime permission requests
- **shared_preferences**: Key-value storage

## Testing

The app is primarily designed for Android devices due to:
- SMS reading limitations on iOS
- Android Alarm Manager being Android-specific

For testing:
1. Use a physical Android device (recommended)
2. Or use Android emulator with SMS simulation

## Future Enhancements

Potential improvements:
- Add notification for alerts
- Support multiple Slack channels
- SMS filtering by sender
- Battery history tracking
- Custom alert messages
- Support for multiple monitoring times
