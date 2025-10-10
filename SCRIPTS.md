# Development Scripts Guide

This project includes automated scripts to streamline your development workflow.

---

## 📜 Available Scripts

### Platform-Specific Scripts
- **macOS/Linux**: `.sh` scripts (bash)
- **Windows**: `.bat` scripts (batch files)

---

### 1. `run_app.sh` / `run_app.bat` - Simple Run Script

#### macOS/Linux (`run_app.sh`)

**Purpose**: Basic script that pulls code, sets up dependencies, and runs the app.

**Usage**:
```bash
# macOS/Linux
./run_app.sh

# Windows
run_app.bat
```

**What it does (macOS)**:
1. ✅ Pulls latest code from Git
2. ✅ Runs `flutter pub get`
3. ✅ Runs `flutter pub run build_runner build` (if build_runner is in dependencies)
4. ✅ Checks if iOS Simulator is running
5. ✅ Opens iOS Simulator if not running
6. ✅ Waits for simulator to fully boot
7. ✅ Launches the Flutter app

**Features**:
- Colored output for easy reading
- Automatic simulator detection and startup
- Error handling at each step
- Progress indicators

#### Windows (`run_app.bat`)

**What it does**:
1. ✅ Pulls latest code from Git
2. ✅ Runs `flutter pub get`
3. ✅ Runs `flutter pub run build_runner build` (if available)
4. ✅ Launches the Flutter app on connected device/emulator

**Note**: Windows script doesn't auto-start emulators. Start your Android emulator manually first.

---

### 2. `dev.sh` / `dev.bat` - Enhanced Development Script

**Purpose**: Comprehensive development script with multiple commands for setup, Android, and maintenance.

**Usage**:
```bash
# macOS/Linux
./dev.sh [command]

# Windows
dev.bat [command]
```

**Available Commands (macOS/Linux)**:

#### `./dev.sh ios`
Runs the complete workflow for iOS development:
- Pulls latest code
- Installs dependencies
- Runs build_runner
- Starts iOS Simulator (if needed)
- Launches app

#### `./dev.sh android`
Runs the complete workflow for Android development:
- Pulls latest code
- Installs dependencies
- Runs build_runner
- Starts Android Emulator (if needed)
- Launches app

#### `./dev.sh setup`
First-time project setup:
- Pulls latest code
- Installs all dependencies
- Runs Flutter doctor for diagnostics
- Runs build_runner
- Verifies project is ready

#### `./dev.sh clean`
Cleans and rebuilds the project:
- Runs `flutter clean`
- Deletes all generated files (*.g.dart, *.freezed.dart)
- Reinstalls dependencies
- Regenerates code with build_runner

**Available Commands (Windows)**:

#### `dev.bat android`
Runs the workflow for Android development (emulator must be started manually first)

#### `dev.bat setup`
First-time project setup (same as macOS)

#### `dev.bat clean`
Cleans and rebuilds the project (same as macOS)

---

## 🚀 Quick Start

### First Time Setup

#### macOS/Linux
```bash
# Make scripts executable (already done)
chmod +x run_app.sh dev.sh

# Run first-time setup
./dev.sh setup

# Start developing
./dev.sh ios      # For iOS
./dev.sh android  # For Android
```

#### Windows
```cmd
# Run first-time setup
dev.bat setup

# Start developing (start emulator first)
dev.bat android
```

### Daily Development Workflow

#### macOS/Linux
```bash
# Simple workflow
./run_app.sh           # iOS only

# Enhanced workflow
./dev.sh ios           # iOS with full automation
./dev.sh android       # Android with full automation
```

#### Windows
```cmd
# Simple workflow
run_app.bat            # Run on connected device

# Enhanced workflow
dev.bat android        # Android (start emulator first)
```

---

## 📋 Prerequisites

### For iOS Development
- ✅ Xcode installed
- ✅ iOS Simulator available
- ✅ Command Line Tools installed:
  ```bash
  xcode-select --install
  ```

### For Android Development
- ✅ Android Studio installed
- ✅ At least one Android Virtual Device (AVD) created
- ✅ Android SDK and emulator in PATH
- ✅ `adb` command available

### General Requirements
- ✅ Flutter SDK installed and in PATH
- ✅ Git installed
- ✅ Project cloned from repository

---

## 🔧 Troubleshooting

### Script Permission Denied
```bash
# Make scripts executable
chmod +x run_app.sh dev.sh
```

### iOS Simulator Not Found
```bash
# Check if simulators are available
xcrun simctl list devices

# Open Xcode and install simulators if needed
open /Applications/Xcode.app
```

### Android Emulator Not Starting
```bash
# Check available emulators
emulator -list-avds

# If empty, create one in Android Studio:
# Tools → Device Manager → Create Device
```

### Build Runner Fails
```bash
# Clean and regenerate
./dev.sh clean

# Or manually:
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Git Pull Fails
```bash
# Check git status
git status

# Resolve conflicts or stash changes
git stash
./dev.sh ios
```

---

## 🎨 Script Features

### Color-Coded Output
- 🔵 **Blue**: Step headers
- 🟢 **Green**: Success messages
- 🟡 **Yellow**: Info/warnings
- 🔴 **Red**: Errors

### Smart Simulator Detection
- Automatically detects if simulator is already running
- Starts simulator only if needed
- Waits for full boot before launching app
- Timeout protection (60 seconds max wait)

### Error Handling
- Exits on any error (set -e)
- Clear error messages
- Step-by-step progress tracking

---

## 🔄 Workflow Comparison

### Without Scripts (Manual)
```bash
git pull
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
open -a Simulator
# Wait manually...
flutter run
```
**Time**: ~3-5 minutes (with manual waiting)

### With Scripts
```bash
./dev.sh ios
```
**Time**: ~2-3 minutes (automated)

---

## 📝 Customization

### Changing Default Simulator
Edit `dev.sh` or `run_app.sh` to specify a different simulator:

```bash
# Find available simulators
xcrun simctl list devices

# Modify script to use specific device
DEVICE_ID="<your-device-udid>"
flutter run -d "$DEVICE_ID"
```

### Adding Pre-Launch Checks
Add custom checks before running:

```bash
# Example: Check for specific file
if [ ! -f ".env" ]; then
    print_error ".env file not found"
    exit 1
fi
```

### Running in Background
To run the app in background mode:

```bash
# Modify flutter run command
flutter run -d "$DEVICE_ID" &
```

---

## 🎯 Best Practices

### When to Use Each Script

**Use `run_app.sh`**:
- Daily iOS development
- Quick testing
- Simple workflow

**Use `dev.sh ios`**:
- More control needed
- Part of larger workflow
- Multiple platform development

**Use `dev.sh android`**:
- Android development
- Cross-platform testing

**Use `dev.sh setup`**:
- First time setup
- After cloning repo
- New team member onboarding

**Use `dev.sh clean`**:
- Build issues
- Generated code problems
- After major changes

---

## 🔐 Security Notes

- Scripts run `git pull` automatically
- Ensure you're on the correct branch before running
- Review changes after pull if working with sensitive code
- Scripts do NOT auto-commit or push code

---

## 🐛 Known Limitations

1. **iOS only on macOS**: Simulator scripts require macOS with Xcode
2. **Android requires setup**: Emulator must be created beforehand
3. **Single emulator**: Scripts start the first available emulator
4. **No parallel runs**: Can't run iOS and Android simultaneously

---

## 📞 Need Help?

- Check script output for detailed error messages
- Run `flutter doctor` to diagnose Flutter issues
- Review `development_process.md` for development guidelines
- Ask team for clarification on setup issues

---

## 🎉 Quick Reference

### macOS/Linux
```bash
# Daily workflow
./dev.sh ios          # Run on iOS
./dev.sh android      # Run on Android

# Maintenance
./dev.sh setup        # First-time setup
./dev.sh clean        # Clean rebuild

# Simple option
./run_app.sh          # Quick iOS run
```

### Windows
```cmd
# Daily workflow
dev.bat android       # Run on Android (emulator must be running)

# Maintenance
dev.bat setup         # First-time setup
dev.bat clean         # Clean rebuild

# Simple option
run_app.bat           # Quick run on connected device
```

---

**Happy coding! 🚀**

