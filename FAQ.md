# Frequently Asked Questions (FAQ)

## General

### Q: What platforms does this app support?
**A:** The app is primarily designed for Android (API 21+). iOS has limited support as SMS reading is not available on iOS, and alarm scheduling works differently.

### Q: Do I need a Slack workspace?
**A:** Yes, you need access to a Slack workspace where you can create incoming webhooks. You can create a free workspace at https://slack.com/

### Q: Is my data secure?
**A:** The app stores settings locally on your device using SharedPreferences. SMS messages and battery data are sent directly to your Slack webhook URL. No data is stored on external servers.

## Setup

### Q: How do I get a Slack webhook URL?
**A:** 
1. Go to https://api.slack.com/messaging/webhooks
2. Click "Create your Slack app"
3. Choose "From scratch"
4. Name your app and select your workspace
5. Click "Incoming Webhooks"
6. Activate incoming webhooks
7. Click "Add New Webhook to Workspace"
8. Choose a channel and authorize
9. Copy the webhook URL

### Q: What time format should I use?
**A:** Use 24-hour format (HH:MM). Examples:
- 09:00 (9:00 AM)
- 13:30 (1:30 PM)
- 23:45 (11:45 PM)

### Q: Why do I need to grant SMS permissions?
**A:** The app needs SMS read permission to detect incoming messages and forward them to Slack. This permission is only used for this purpose.

### Q: Why do I need exact alarm permission?
**A:** Android 12+ requires explicit permission to schedule exact alarms. This ensures the battery check happens at the exact time you specify.

## Usage

### Q: When will battery alerts be sent?
**A:** Battery alerts are sent once per day at the time you configure, but ONLY if the battery level is below your threshold (not equal to).

### Q: Will SMS forwarding work immediately?
**A:** Yes, once you save the settings and grant SMS permissions, any new incoming SMS will be forwarded to Slack immediately.

### Q: Does the app work in the background?
**A:** Yes, both battery monitoring and SMS forwarding work in the background. Battery monitoring uses Android Alarm Manager which is reliable even when the app is closed.

### Q: Will it work after device restart?
**A:** Yes, the alarm is configured to reschedule automatically after device reboot.

## Troubleshooting

### Q: I'm not receiving alerts in Slack. What should I check?
**A:** 
1. Verify your webhook URL is correct
2. Test the webhook manually using curl or Postman
3. Check your internet connection
4. Ensure the Slack channel still exists
5. Check Android battery optimization settings aren't killing the app

### Q: The app doesn't read SMS messages. Why?
**A:** 
1. Ensure you granted SMS read permission
2. Check if another app is set as default SMS app (this app doesn't need to be default)
3. Verify the webhook URL is configured
4. Check Android logs for error messages

### Q: Code generation fails. What should I do?
**A:** 
1. Run `flutter clean`
2. Run `flutter pub get`
3. Try `flutter pub run build_runner build --delete-conflicting-outputs`
4. Check for syntax errors in `lib/api/slack_api.dart`

### Q: The alarm doesn't trigger at the specified time. Why?
**A:** 
1. Check if you granted exact alarm permission
2. Verify the time format is correct (HH:MM)
3. Check Android battery optimization settings
4. Some manufacturers have aggressive battery saving - add the app to whitelist

### Q: Build fails with Gradle errors. What should I do?
**A:** 
1. Ensure you have Android SDK installed
2. Update Android Studio and SDK tools
3. Check `android/local.properties` points to correct SDK path
4. Try `flutter clean` and rebuild

## Privacy & Permissions

### Q: What data does the app collect?
**A:** The app only collects:
- SMS message content (when received)
- Battery level (at scheduled time)
- Your configuration (webhook URL, time, threshold)

All data is stored locally or sent directly to your Slack webhook.

### Q: Can I use this without Slack?
**A:** Currently, the app is designed specifically for Slack webhooks. However, you could modify the code to work with other webhook services that accept JSON POST requests.

### Q: Does the app share my data with third parties?
**A:** No. The app only sends data to the Slack webhook URL you provide. No analytics or tracking is implemented.

## Development

### Q: Can I modify the code?
**A:** Yes! The app is open source. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Q: How do I add new features?
**A:** See [DEVELOPMENT.md](DEVELOPMENT.md) for architecture details and development guidelines.

### Q: Can I use this as a template for my own app?
**A:** Absolutely! The code is MIT licensed. You're free to use, modify, and distribute it.

## Support

### Q: Where can I report bugs?
**A:** Please open an issue on the GitHub repository with details about the bug, including:
- Device model and Android version
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs if available

### Q: How can I request new features?
**A:** Open an issue on GitHub with the "feature request" label. Describe the feature and your use case.

### Q: Can I contribute?
**A:** Yes! We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
