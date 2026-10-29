@echo off
title Vintech School Desktop (Windows)
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - WINDOWS DESKTOP RUNNER (SUPER FAST & LOW RAM)
echo =======================================================================
echo.
echo Menjalankan aplikasi secara native di Windows Desktop...
echo.
call flutter run -d windows
echo.
pause
