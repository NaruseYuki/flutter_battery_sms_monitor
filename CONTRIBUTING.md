# Contributing to Flutter Battery & SMS Monitor

Thank you for your interest in contributing to this project!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/flutter_battery_sms_monitor.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit your changes: `git commit -m "Add your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

See [BUILD.md](BUILD.md) for detailed build instructions.

Quick start:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Code Style

- Follow the Dart style guide: https://dart.dev/guides/language/effective-dart
- Use `flutter analyze` to check for issues
- Format code with `flutter format .`
- Add comments for complex logic
- Use meaningful variable and function names

## Testing

- Add tests for new features
- Ensure existing tests pass
- Test on physical Android devices when possible
- Verify permissions work correctly

## Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the DEVELOPMENT.md if you change architecture
3. Ensure your code follows the style guidelines
4. Make sure all tests pass
5. Update the documentation

## Reporting Bugs

When reporting bugs, please include:
- Flutter version
- Android version
- Device model
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable

## Feature Requests

We welcome feature requests! Please:
- Check if the feature has already been requested
- Explain the use case
- Describe the expected behavior
- Consider if it fits the app's scope

## Questions?

Feel free to open an issue for questions or discussions.

Thank you for contributing!
