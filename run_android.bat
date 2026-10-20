@echo off
title Vintech Mobile App Runner
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - APP RUNNER (EMULATOR-5554)
echo =======================================================================
echo.
echo Menonaktifkan pop-up keyboard virtual layar di emulator...
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell settings put secure show_ime_with_hard_keyboard 0 >nul 2>&1
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell input keyevent 111 >nul 2>&1

echo Menjalankan aplikasi Flutter di Android Emulator...
echo.
call flutter run -d emulator-5554
if errorlevel 1 (
    echo.
    echo Perangkat emulator-5554 tidak terdeteksi, mencoba auto-detect...
    call flutter run
)
echo.
pause
