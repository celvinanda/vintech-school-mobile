@echo off
title Vintech Mobile App Runner
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - APP RUNNER
echo =======================================================================
echo.

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "DEVICE_ID="

if not exist "%ADB%" goto :auto_detect

:: 1. Cari perangkat Android aktif (Emulator maupun Perangkat Fisik Xiaomi via USB)
for /f "skip=1 tokens=1,2" %%A in ('"%ADB%" devices') do (
    if "%%B"=="device" (
        set "DEVICE_ID=%%A"
        goto :launch_device
    )
)

:auto_detect
echo [TARGET] Tidak ada perangkat ADB terdeteksi, mencoba auto-detect Flutter...
call flutter run
goto :done

:launch_device
echo [TARGET] Perangkat Android terdeteksi: %DEVICE_ID%
echo.

:: Jika emulator, matikan pop-up keyboard di layar
echo %DEVICE_ID% | findstr /i "emulator" >nul
if not errorlevel 1 (
    echo Menonaktifkan pop-up keyboard virtual di emulator...
    "%ADB%" -s %DEVICE_ID% shell settings put secure show_ime_with_hard_keyboard 0 >nul 2>&1
    "%ADB%" -s %DEVICE_ID% shell input keyevent 111 >nul 2>&1
)

echo Meluncurkan aplikasi ke %DEVICE_ID%...
call flutter run -d %DEVICE_ID%

:done
echo.
pause
