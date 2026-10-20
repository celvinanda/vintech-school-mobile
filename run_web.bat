@echo off
title Vintech School Web (Chrome)
color 0B
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - WEB PREVIEW (CHROME)
echo =======================================================================
echo.
echo Menjalankan aplikasi di Google Chrome...
echo.
call flutter run -d chrome
echo.
pause
