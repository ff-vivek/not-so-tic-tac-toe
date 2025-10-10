@echo off
REM Gridlock X & O Evolved - Enhanced Windows Development Script
REM Usage: dev.bat [android|setup|clean]

setlocal enabledelayedexpansion

if "%1"=="" goto show_usage
if "%1"=="android" goto run_android
if "%1"=="setup" goto setup_project
if "%1"=="clean" goto clean_project
goto show_usage

:show_usage
echo.
echo ====================================================
echo  Gridlock X ^& O Evolved - Dev Script
echo ====================================================
echo.
echo Usage: dev.bat [command]
echo.
echo Commands:
echo   android    Pull code, setup, and run on Android emulator
echo   setup      First-time project setup
echo   clean      Clean and rebuild project
echo.
echo Examples:
echo   dev.bat android    # Run on Android
echo   dev.bat setup      # Setup project
echo.
goto :eof

:run_android
echo.
echo ====================================================
echo  Running on Android
echo ====================================================
echo.

echo [STEP 1] Pulling latest code...
git pull
if errorlevel 1 exit /b 1

echo [STEP 2] Installing dependencies...
call flutter pub get
if errorlevel 1 exit /b 1

echo [STEP 3] Running build_runner...
findstr /C:"build_runner" pubspec.yaml >nul
if %errorlevel% equ 0 (
    call flutter pub run build_runner build --delete-conflicting-outputs
    if errorlevel 1 exit /b 1
)

echo [STEP 4] Checking Android emulators...
adb devices | findstr /C:"emulator" >nul
if errorlevel 1 (
    echo [INFO] No emulator running. Please start one manually.
    echo Run: emulator -avd ^<avd-name^>
    exit /b 1
)

echo [STEP 5] Launching app on Android...
call flutter run
goto :eof

:setup_project
echo.
echo ====================================================
echo  Setting Up Project
echo ====================================================
echo.

git pull

echo [INFO] Installing dependencies...
call flutter pub get

echo [INFO] Running Flutter doctor...
call flutter doctor

findstr /C:"build_runner" pubspec.yaml >nul
if %errorlevel% equ 0 (
    call flutter pub run build_runner build --delete-conflicting-outputs
)

echo [SUCCESS] Setup complete! Run 'dev.bat android' to launch.
goto :eof

:clean_project
echo.
echo ====================================================
echo  Cleaning Project
echo ====================================================
echo.

echo [INFO] Running flutter clean...
call flutter clean

echo [INFO] Removing generated files...
for /r %%i in (*.g.dart) do del "%%i"
for /r %%i in (*.freezed.dart) do del "%%i"

echo [INFO] Reinstalling dependencies...
call flutter pub get

findstr /C:"build_runner" pubspec.yaml >nul
if %errorlevel% equ 0 (
    call flutter pub run build_runner build --delete-conflicting-outputs
)

echo [SUCCESS] Project cleaned successfully
goto :eof

