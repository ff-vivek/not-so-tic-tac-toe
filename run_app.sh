#!/bin/bash

# Gridlock X & O Evolved - Development Run Script
# This script automates: git pull → flutter pub get → build_runner → iOS simulator → flutter run

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Step 1: Git Pull
print_step "Step 1: Pulling latest code from Git"
if git pull; then
    print_success "Git pull completed successfully"
else
    print_error "Git pull failed. Please resolve any conflicts and try again."
    exit 1
fi

# Step 2: Flutter pub get
print_step "Step 2: Installing Flutter dependencies"
if flutter pub get; then
    print_success "Dependencies installed successfully"
else
    print_error "Flutter pub get failed"
    exit 1
fi

# Step 3: Build Runner (if needed)
print_step "Step 3: Running build_runner"
print_info "This may take a few minutes..."

# Check if build_runner is in dependencies
if grep -q "build_runner" pubspec.yaml; then
    if flutter pub run build_runner build --delete-conflicting-outputs; then
        print_success "Build runner completed successfully"
    else
        print_error "Build runner failed"
        exit 1
    fi
else
    print_info "build_runner not found in pubspec.yaml, skipping..."
fi

# Step 4: Check iOS Simulator
print_step "Step 4: Checking iOS Simulator"

# Function to check if simulator is running
is_simulator_running() {
    xcrun simctl list devices | grep -q "Booted"
}

# Function to get booted simulator name
get_booted_simulator() {
    xcrun simctl list devices | grep "Booted" | head -1 | sed 's/(.*//' | xargs
}

if is_simulator_running; then
    SIMULATOR_NAME=$(get_booted_simulator)
    print_success "iOS Simulator is already running: $SIMULATOR_NAME"
else
    print_info "iOS Simulator is not running. Starting it now..."
    
    # Open Simulator app
    open -a Simulator
    
    print_info "Waiting for simulator to boot..."
    
    # Wait for simulator to boot (max 60 seconds)
    COUNTER=0
    MAX_WAIT=60
    
    while ! is_simulator_running; do
        if [ $COUNTER -ge $MAX_WAIT ]; then
            print_error "Simulator failed to start within $MAX_WAIT seconds"
            exit 1
        fi
        
        echo -n "."
        sleep 2
        COUNTER=$((COUNTER + 2))
    done
    
    echo ""
    SIMULATOR_NAME=$(get_booted_simulator)
    print_success "iOS Simulator started successfully: $SIMULATOR_NAME"
    
    # Give simulator extra time to fully initialize
    print_info "Waiting 5 more seconds for simulator to fully initialize..."
    sleep 5
fi

# Step 5: Run Flutter App
print_step "Step 5: Launching Flutter App"
print_info "Running app on: $SIMULATOR_NAME"
print_info "Press 'q' in the terminal to quit the app"
echo ""

# Run flutter with hot reload enabled
flutter run -d "$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(//' | sed 's/).*//')"

