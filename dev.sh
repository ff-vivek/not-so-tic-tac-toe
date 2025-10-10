#!/bin/bash

# Gridlock X & O Evolved - Enhanced Development Script
# Usage: ./dev.sh [ios|android|setup|clean]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║     Gridlock X & O Evolved - Dev Script          ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Git pull
git_pull() {
    print_step "Pulling latest code from Git"
    if git pull; then
        print_success "Code updated successfully"
    else
        print_error "Git pull failed"
        exit 1
    fi
}

# Flutter pub get
flutter_deps() {
    print_step "Installing dependencies"
    if flutter pub get; then
        print_success "Dependencies installed"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Build runner
run_build_runner() {
    if grep -q "build_runner" pubspec.yaml; then
        print_step "Running build_runner"
        if flutter pub run build_runner build --delete-conflicting-outputs; then
            print_success "Code generation completed"
        else
            print_error "Build runner failed"
            exit 1
        fi
    fi
}

# iOS Simulator
start_ios_simulator() {
    print_step "Setting up iOS Simulator"
    
    if xcrun simctl list devices | grep -q "Booted"; then
        SIMULATOR_NAME=$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/(.*//' | xargs)
        print_success "Simulator already running: $SIMULATOR_NAME"
    else
        print_info "Starting iOS Simulator..."
        open -a Simulator
        
        COUNTER=0
        while ! xcrun simctl list devices | grep -q "Booted"; do
            if [ $COUNTER -ge 60 ]; then
                print_error "Simulator timeout"
                exit 1
            fi
            echo -n "."
            sleep 2
            COUNTER=$((COUNTER + 2))
        done
        echo ""
        print_success "Simulator started"
        sleep 5
    fi
}

# Run on iOS
run_ios() {
    print_banner
    git_pull
    flutter_deps
    run_build_runner
    start_ios_simulator
    
    print_step "Launching app on iOS"
    
    # Prefer specific device: iPhone 16 Plus
    PREFERRED_DEVICE="2AFF1AEA-9D1C-420E-ACE5-DA10B7493788"
    
    if xcrun simctl list devices | grep -q "$PREFERRED_DEVICE"; then
        print_info "Using iPhone 16 Plus simulator"
        flutter run -d "$PREFERRED_DEVICE"
    else
        print_info "iPhone 16 Plus not found, using booted simulator"
        DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(//' | sed 's/).*//')
        flutter run -d "$DEVICE_ID"
    fi
}

# Run on Android
run_android() {
    print_banner
    git_pull
    flutter_deps
    run_build_runner
    
    print_step "Checking Android emulators"
    
    # Check if any emulator is running
    if adb devices | grep -q "emulator"; then
        print_success "Android emulator already running"
    else
        print_info "Starting Android emulator..."
        
        # Get list of available emulators
        EMULATORS=$(emulator -list-avds)
        
        if [ -z "$EMULATORS" ]; then
            print_error "No Android emulators found. Please create one in Android Studio."
            exit 1
        fi
        
        # Start first available emulator
        FIRST_EMULATOR=$(echo "$EMULATORS" | head -1)
        print_info "Starting emulator: $FIRST_EMULATOR"
        emulator -avd "$FIRST_EMULATOR" &
        
        # Wait for emulator to boot
        print_info "Waiting for emulator to boot..."
        adb wait-for-device
        
        # Wait for boot to complete
        while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
            echo -n "."
            sleep 2
        done
        echo ""
        print_success "Emulator started"
    fi
    
    print_step "Launching app on Android"
    flutter run
}

# Setup project
setup_project() {
    print_banner
    print_step "Setting up project for first time"
    
    git_pull
    
    print_info "Installing Flutter dependencies..."
    flutter_deps
    
    print_info "Running Flutter doctor..."
    flutter doctor
    
    run_build_runner
    
    print_success "Setup complete! Run './dev.sh ios' or './dev.sh android' to launch."
}

# Clean project
clean_project() {
    print_banner
    print_step "Cleaning project"
    
    print_info "Running flutter clean..."
    flutter clean
    
    print_info "Removing generated files..."
    find . -name "*.g.dart" -delete
    find . -name "*.freezed.dart" -delete
    
    print_info "Reinstalling dependencies..."
    flutter pub get
    
    run_build_runner
    
    print_success "Project cleaned successfully"
}

# Show usage
show_usage() {
    print_banner
    echo "Usage: ./dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  ios        Pull code, setup, and run on iOS simulator"
    echo "  android    Pull code, setup, and run on Android emulator"
    echo "  setup      First-time project setup"
    echo "  clean      Clean and rebuild project"
    echo ""
    echo "Examples:"
    echo "  ./dev.sh ios       # Run on iOS"
    echo "  ./dev.sh android   # Run on Android"
    echo "  ./dev.sh setup     # Setup project"
    echo ""
}

# Main logic
case "$1" in
    ios)
        run_ios
        ;;
    android)
        run_android
        ;;
    setup)
        setup_project
        ;;
    clean)
        clean_project
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

