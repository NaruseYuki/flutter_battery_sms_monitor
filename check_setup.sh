#!/bin/bash
# Script to check Flutter environment and project setup

echo "Checking Flutter environment..."
echo "================================"

# Check Flutter installation
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed or not in PATH"
    echo "   Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
else
    echo "✓ Flutter is installed"
    flutter --version
fi

echo ""
echo "Checking project setup..."
echo "================================"

# Check if pubspec.yaml exists
if [ -f "pubspec.yaml" ]; then
    echo "✓ pubspec.yaml found"
else
    echo "❌ pubspec.yaml not found"
    exit 1
fi

# Check if required directories exist
if [ -d "lib" ]; then
    echo "✓ lib directory exists"
else
    echo "❌ lib directory not found"
    exit 1
fi

if [ -d "android" ]; then
    echo "✓ android directory exists"
else
    echo "⚠ android directory not found (Android builds will not work)"
fi

echo ""
echo "Running flutter doctor..."
echo "================================"
flutter doctor

echo ""
echo "Checking for required generated files..."
echo "================================"

if [ -f "lib/api/slack_api.g.dart" ]; then
    echo "✓ slack_api.g.dart found"
else
    echo "⚠ slack_api.g.dart not found"
    echo "  Run: flutter pub run build_runner build --delete-conflicting-outputs"
fi

echo ""
echo "Project check complete!"
