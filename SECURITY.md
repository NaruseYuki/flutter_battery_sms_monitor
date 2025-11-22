# Security Considerations

## Overview

This document outlines security considerations for the Flutter Battery & SMS Monitor app.

## Data Privacy

### Local Data Storage
- Settings (webhook URL, time, threshold) are stored using SharedPreferences
- SharedPreferences on Android is stored in app-private storage
- Data is not encrypted at rest - consider this when storing sensitive webhook URLs
- No user data is collected or transmitted to third-party servers

### Data Transmission
- SMS content and battery levels are sent directly to user-configured Slack webhook
- Communication uses HTTPS (Slack webhooks are HTTPS-only)
- No intermediary servers or analytics services are used
- Webhook URL should be kept confidential as it provides direct access to Slack channel

## Permissions

### SMS Permissions
- `READ_SMS`: Required to read incoming SMS messages
- `RECEIVE_SMS`: Required to receive SMS broadcasts
- These permissions are sensitive and should be granted carefully
- App only uses SMS data to forward to Slack webhook
- No SMS data is stored locally or sent elsewhere

### Alarm Permissions
- `SCHEDULE_EXACT_ALARM`: Required for precise battery monitoring time
- `WAKE_LOCK`: Allows waking device to check battery level
- `RECEIVE_BOOT_COMPLETED`: Reschedules alarms after device restart

### Internet Permission
- `INTERNET`: Required to send data to Slack webhook
- No other network access is performed

## Best Practices

### For Users

1. **Protect Your Webhook URL**
   - Treat webhook URL like a password
   - Don't share screenshots containing the webhook URL
   - Revoke and regenerate webhook if compromised
   - Use Slack's webhook management to monitor usage

2. **Review Permissions**
   - Only grant permissions if you understand and need the functionality
   - Review Android Settings > Apps > Permissions regularly
   - Consider implications of SMS forwarding for sensitive messages

3. **Network Security**
   - Use secure WiFi networks
   - Be aware that SMS content will be visible in Slack channel
   - Configure appropriate Slack channel permissions

4. **Device Security**
   - Use device lock screen
   - Keep Android OS updated
   - Install from trusted sources only

### For Developers

1. **Code Security**
   - Keep dependencies updated for security patches
   - Review dependency vulnerabilities regularly
   - Use `flutter pub outdated` to check for updates

2. **Input Validation**
   - Webhook URL is not validated beyond basic format checking
   - Consider adding URL validation in production
   - Time input is validated to prevent invalid values

3. **Error Handling**
   - Errors are caught and logged but not exposed to user
   - Consider implementing proper logging framework for production
   - Don't expose sensitive information in error messages

4. **Build Security**
   - Use ProGuard/R8 for release builds to obfuscate code
   - Sign APK with secure keystore
   - Don't commit keystore to version control

## Potential Risks

### High Risk
- **Webhook URL Exposure**: If webhook URL is leaked, unauthorized parties can post to Slack
  - Mitigation: Keep URL confidential, use Slack's access controls
  
- **SMS Content Exposure**: Sensitive SMS messages will be forwarded to Slack
  - Mitigation: Configure Slack channel with appropriate access controls, consider selective forwarding

### Medium Risk
- **Unencrypted Local Storage**: Webhook URL stored in plain text in SharedPreferences
  - Mitigation: Use Android's encrypted SharedPreferences for sensitive data
  
- **Battery Optimization**: Some manufacturers may kill background tasks
  - Mitigation: Guide users to whitelist app in battery optimization

### Low Risk
- **Permission Abuse**: App could theoretically read all SMS
  - Mitigation: Code is open source, can be audited
  
- **Network Interception**: HTTPS prevents MITM attacks
  - No additional mitigation needed (Slack uses HTTPS)

## Compliance Considerations

### GDPR (if applicable)
- SMS messages may contain personal data
- Users should understand data processing (forwarding to Slack)
- Consider adding privacy policy if distributing widely
- No analytics or tracking implemented

### Android Permissions Policy
- App declares all required permissions in manifest
- Runtime permissions requested with clear purpose
- Follows Android best practices for permission requests

## Recommendations for Production

1. **Encrypt Stored Data**
   ```dart
   // Use encrypted shared preferences
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';
   ```

2. **Add Privacy Policy**
   - Explain what data is collected and how it's used
   - Link to policy in app and Play Store listing

3. **Implement Certificate Pinning**
   - Pin Slack's certificate for additional HTTPS security
   - Prevents MITM attacks even if device trusts malicious CA

4. **Add Webhook URL Validation**
   - Verify URL matches Slack webhook format
   - Test webhook before saving settings

5. **Implement Rate Limiting**
   - Prevent excessive SMS forwarding (e.g., SMS flood)
   - Add cooldown between Slack posts if needed

6. **Add Logging Framework**
   - Use proper logging instead of print statements
   - Ensure logs don't contain sensitive data
   - Implement crash reporting (with user consent)

7. **Regular Security Audits**
   - Review dependencies for vulnerabilities
   - Use `flutter pub audit` (when available)
   - Monitor Slack webhook usage for anomalies

## Security Contacts

If you discover a security vulnerability, please:
1. Do NOT open a public issue
2. Contact repository maintainers privately
3. Allow reasonable time for fix before disclosure
4. Provide detailed information to reproduce

## Security Updates

- Monitor dependencies: `flutter pub outdated`
- Check Android security bulletins
- Keep Flutter SDK updated
- Review Slack's security advisories

Last Updated: 2025-11-21
