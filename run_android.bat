@echo off
title Vintech Mobile App Runner
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - APP RUNNER (EMULATOR-5554)
echo =======================================================================
echo.
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
