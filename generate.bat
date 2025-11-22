@echo off
REM Script to generate code for Retrofit and JSON serialization

echo Starting code generation...

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Flutter is not installed. Please install Flutter first.
    exit /b 1
)

REM Get dependencies
echo Getting dependencies...
call flutter pub get

REM Run build_runner
echo Running build_runner to generate code...
call flutter pub run build_runner build --delete-conflicting-outputs

if %ERRORLEVEL% EQU 0 (
    echo Code generation completed successfully!
    echo Generated files:
    echo   - lib/api/slack_api.g.dart
) else (
    echo Code generation failed. Please check the error messages above.
    exit /b 1
)
