# Project Summary

## Overview

Flutter Battery & SMS Monitor is a mobile application designed for Android that provides automated monitoring and alerting capabilities for battery levels and SMS messages through Slack integration.

## What It Does

1. **Battery Monitoring**: Automatically checks battery level at a scheduled time each day and sends alerts to Slack when battery is low
2. **SMS Forwarding**: Forwards incoming SMS messages to Slack in real-time
3. **Easy Configuration**: Simple UI to configure monitoring settings

## Key Technologies

- **Flutter**: Cross-platform UI framework (v3.0+)
- **Retrofit**: Type-safe HTTP client for Slack API
- **Android Alarm Manager Plus**: Reliable background task scheduling
- **Battery Plus**: Battery level monitoring
- **SMS Advanced**: SMS reading capabilities

## Project Structure

```
flutter_battery_sms_monitor/
├── lib/
│   ├── api/
│   │   └── slack_api.dart          # Retrofit API client
│   ├── services/
│   │   ├── battery_monitor_service.dart  # Battery monitoring logic
│   │   └── sms_monitor_service.dart      # SMS monitoring logic
│   ├── screens/
│   │   └── home_screen.dart        # Main UI screen
│   └── main.dart                   # App entry point
├── android/                        # Android platform files
├── ios/                           # iOS platform files
├── test/                          # Unit and widget tests
└── docs/                          # Additional documentation

Documentation:
├── README.md              # Main documentation
├── BUILD.md              # Build instructions
├── DEVELOPMENT.md        # Architecture & development guide
├── FAQ.md                # Frequently asked questions
├── CONTRIBUTING.md       # Contribution guidelines
├── SECURITY.md           # Security considerations
└── LICENSE               # MIT License
```

## How It Works

### Battery Monitoring Flow
1. User configures time (e.g., "09:00") and threshold (e.g., "20%")
2. Android Alarm Manager schedules daily alarm
3. At scheduled time, alarm triggers battery check
4. If battery < threshold, alert sent to Slack via webhook
5. Process repeats daily

### SMS Monitoring Flow
1. User grants SMS permissions and configures webhook
2. App registers SMS receiver
3. When SMS arrives, receiver is notified
4. SMS content formatted and sent to Slack
5. Process happens automatically for all incoming SMS

## Core Features

✅ **Scheduled Battery Checks**
- Daily monitoring at user-defined time
- Customizable battery threshold
- Reliable alarm scheduling

✅ **Real-time SMS Forwarding**
- Immediate notification to Slack
- Full message content including sender
- No message storage or logging

✅ **Simple Configuration**
- Single screen for all settings
- Visual monitoring status
- Real-time battery level display

✅ **Robust Background Operation**
- Works when app is closed
- Survives device reboot
- Minimal battery impact

## Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| Battery Monitoring | ✅ Full | ⚠️ Limited |
| SMS Reading | ✅ Full | ❌ Not Available |
| Background Alarms | ✅ Full | ⚠️ Different API |

**Recommendation**: Use on Android for full functionality

## Requirements

### System Requirements
- Android 5.0 (API 21) or higher
- Internet connection
- Slack workspace with webhook access

### Permissions Required
- SMS reading and receiving
- Exact alarm scheduling
- Internet access
- Wake lock
- Boot completed receiver

### Development Requirements
- Flutter SDK 3.0+
- Android Studio / VS Code
- Android SDK (API 21+)
- Dart SDK (included with Flutter)

## Quick Start

```bash
# 1. Clone repository
git clone https://github.com/NaruseYuki/flutter_battery_sms_monitor.git
cd flutter_battery_sms_monitor

# 2. Install dependencies
flutter pub get

# 3. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

## Configuration

Users configure three main settings:

1. **Slack Webhook URL**: Get from https://api.slack.com/messaging/webhooks
2. **Monitor Time**: 24-hour format (HH:MM), e.g., "09:00"
3. **Battery Threshold**: Percentage (0-100), e.g., "20"

## Use Cases

### Personal Use
- Monitor elderly relative's phone battery
- Forward important SMS to Slack workspace
- Ensure critical devices stay charged

### Business Use
- Monitor company phone battery levels
- Forward verification codes to team channel
- Alert team when backup phones need charging

### Development/Testing
- Monitor test device battery during long tests
- Capture SMS-based 2FA codes during testing
- Alert when device needs attention

## Limitations

- Android-only for full functionality
- Requires continuous internet for Slack posting
- Battery optimization may affect reliability on some devices
- No SMS filtering (all SMS are forwarded)
- Single webhook URL (one destination)

## Future Enhancements

Potential improvements (not currently implemented):

- Multiple webhook destinations
- SMS filtering by sender/content
- Battery history tracking
- Custom alert messages
- Multiple monitoring times
- iOS support improvements
- Notification system
- Dark mode
- Localization

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) file

## Support & Documentation

- **Main Docs**: [README.md](README.md)
- **Build Guide**: [BUILD.md](BUILD.md)
- **Development**: [DEVELOPMENT.md](DEVELOPMENT.md)
- **FAQ**: [FAQ.md](FAQ.md)
- **Security**: [SECURITY.md](SECURITY.md)

## Credits

Built with Flutter and uses these excellent packages:
- battery_plus
- android_alarm_manager_plus
- readsms
- retrofit
- dio
- shared_preferences
- permission_handler

## Version

Current Version: 1.0.0

Last Updated: 2025-11-21
