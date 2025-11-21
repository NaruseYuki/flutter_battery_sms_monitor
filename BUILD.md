# Build Instructions

## Prerequisites

1. Install Flutter SDK (https://flutter.dev/docs/get-started/install)
2. Install Android Studio or VS Code with Flutter extensions
3. Set up Android SDK

## Building the App

### 1. Get Dependencies

```bash
flutter pub get
```

### 2. Generate Code (Required)

The app uses code generation for Retrofit and JSON serialization. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `lib/api/slack_api.g.dart`

### 3. Build the App

For Android:
```bash
flutter build apk
```

Or run directly on device/emulator:
```bash
flutter run
```

### 4. Build for Release

```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Development

### Watch Mode for Code Generation

During development, you can run build_runner in watch mode:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will automatically regenerate code when you modify files.

### Troubleshooting

If you encounter build errors:

1. Clean the build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Regenerate code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Check Android SDK configuration in Android Studio

## Testing

Since this is an Android-specific app with hardware dependencies, testing should be done on:
- Physical Android device (recommended)
- Android emulator

Grant required permissions when prompted:
- SMS reading
- Exact alarm scheduling
