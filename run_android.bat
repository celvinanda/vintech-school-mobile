@echo off
title Vintech Mobile App Runner
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - APP RUNNER
echo =======================================================================
echo.

set ADB="%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

:: 1. Periksa apakah Android Emulator (emulator-5554) aktif
if exist %ADB% (
    %ADB% devices | findstr /i "emulator-5554" >nul
    if not errorlevel 1 (
        echo [TARGET] Android Emulator (emulator-5554) aktif.
        echo Menonaktifkan pop-up keyboard virtual layar di emulator...
        %ADB% -s emulator-5554 shell settings put secure show_ime_with_hard_keyboard 0 >nul 2>&1
        %ADB% -s emulator-5554 shell input keyevent 111 >nul 2>&1
        echo Menjalankan aplikasi di emulator-5554...
        call flutter run -d emulator-5554
        goto :done
    )

    :: 2. Periksa apakah perangkat fisik Android terhubung via USB
    %ADB% devices | findstr /i "device$" >nul
    if not errorlevel 1 (
        echo [TARGET] Perangkat fisik Android (Xiaomi / USB) terdeteksi.
        echo Menjalankan aplikasi langsung di perangkat Android...
        call flutter run -d android
        goto :done
    )
)

:: 3. Fallback jika tidak ada ADB atau perangkat spesifik
echo [TARGET] Menjalankan aplikasi Flutter (Auto-Detect)...
call flutter run

:done
echo.
pause
