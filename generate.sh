#!/bin/bash
# Script to generate code for Retrofit and JSON serialization

echo "Starting code generation..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Run build_runner
echo "Running build_runner to generate code..."
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo "✓ Code generation completed successfully!"
    echo "Generated files:"
    echo "  - lib/api/slack_api.g.dart"
else
    echo "✗ Code generation failed. Please check the error messages above."
    exit 1
fi
