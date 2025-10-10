@echo off
REM Gridlock X & O Evolved - Windows Development Script
REM This script automates: git pull, flutter pub get, build_runner, flutter run
REM
REM NOTE: iOS Simulators only work on macOS with Xcode
REM For iOS development, use run_app.sh on macOS
REM This script works with:
REM   - Android emulators (must be started manually)
REM   - Physical Android devices connected via USB
REM   - Chrome (for web development)

echo.
echo ====================================================
echo  Gridlock X ^& O Evolved - Development Run Script
echo  Platform: Windows (Android/Web/Physical Devices)
echo ====================================================
echo.

REM Check if in correct directory
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Please run this script from the project root.
    exit /b 1
)

REM Step 1: Git Pull
echo [STEP 1] Pulling latest code from Git...
git pull
if errorlevel 1 (
    echo [ERROR] Git pull failed
    exit /b 1
)
echo [SUCCESS] Git pull completed
echo.

REM Step 2: Flutter pub get
echo [STEP 2] Installing Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo [ERROR] Flutter pub get failed
    exit /b 1
)
echo [SUCCESS] Dependencies installed
echo.

REM Step 3: Build Runner
echo [STEP 3] Running build_runner...
findstr /C:"build_runner" pubspec.yaml >nul
if %errorlevel% equ 0 (
    call flutter pub run build_runner build --delete-conflicting-outputs
    if errorlevel 1 (
        echo [ERROR] Build runner failed
        exit /b 1
    )
    echo [SUCCESS] Build runner completed
) else (
    echo [INFO] build_runner not found in pubspec.yaml, skipping...
)
echo.

REM Step 4: Run Flutter App
echo [STEP 4] Launching Flutter App...
echo [INFO] Starting app with hot reload enabled
echo [INFO] Press Ctrl+C to quit
echo.

call flutter run

exit /b 0

