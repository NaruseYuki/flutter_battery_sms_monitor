# Flutter Battery & SMS Monitor

A Flutter application that monitors battery levels at scheduled times and forwards SMS messages to Slack.

## Features

### 1. SMS Monitoring
- Automatically reads incoming SMS messages
- Forwards SMS content to Slack using webhooks
- Displays sender, date, and message content

### 2. Battery Monitoring
- Schedule daily battery level checks at a specific time
- Set custom battery threshold for alerts
- Sends alert to Slack when battery level falls below threshold
- Uses Android Alarm Manager for reliable scheduling

### 3. User Interface
- Configure Slack webhook URL
- Set monitoring time (HH:MM format)
- Set battery alert threshold (percentage)
- View current battery level
- Start/stop monitoring with simple buttons

## Dependencies

- `battery_plus`: ^6.0.2 - Battery level monitoring
- `android_alarm_manager_plus`: ^4.0.3 - Scheduled tasks
- `sms_advanced`: ^1.1.0 - SMS reading
- `dio`: ^5.4.0 - HTTP client
- `retrofit`: ^4.0.3 - Type-safe HTTP client
- `permission_handler`: ^11.1.0 - Runtime permissions
- `shared_preferences`: ^2.2.2 - Local storage

## Setup

### 1. Configure Slack Webhook

1. Go to https://api.slack.com/messaging/webhooks
2. Create a new webhook for your workspace
3. Copy the webhook URL (format: `https://hooks.slack.com/services/...`)

### 2. Install the App

```bash
flutter pub get
flutter run
```

### 3. Configure Settings

1. Open the app
2. Enter your Slack webhook URL
3. Set the monitoring time (24-hour format, e.g., "09:00")
4. Set battery threshold percentage (e.g., "20")
5. Tap "Save & Start Monitoring"

### 4. Grant Permissions

The app will request:
- SMS read permission
- Exact alarm scheduling permission

## Usage

### Battery Monitoring
- The app will check battery level at the configured time daily
- If battery level ≤ threshold, an alert is sent to Slack
- Alert format: "⚠️ Battery Alert: Battery level is low at XX%"

### SMS Monitoring
- SMS monitoring starts automatically when settings are saved
- Each incoming SMS is immediately forwarded to Slack
- SMS format includes sender, date, and message body

## Platform Support

- **Android**: Full support (API 21+)
- **iOS**: Limited support (SMS reading not available on iOS)

## Notes

- Battery monitoring uses Android Alarm Manager for reliable scheduling
- Alarms persist after device reboot
- HTTP communication uses Retrofit for type-safe API calls
- Settings are stored locally using SharedPreferences

## License

This project is open source.