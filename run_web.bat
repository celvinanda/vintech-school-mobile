@echo off
title Vintech School Web (Chrome)
color 0B
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - WEB PREVIEW (CHROME)
echo =======================================================================
echo.
echo Membersihkan temporary cache debug...
del /q /f "%TEMP%\flutter_tools.*" >nul 2>&1

echo.
echo Menjalankan aplikasi di Google Chrome (Clean Profile)...
echo.
call flutter run -d chrome --web-browser-flag "--disable-extensions" --web-browser-flag "--disable-default-apps" --web-browser-flag "--no-default-browser-check"
if errorlevel 1 (
    echo.
    echo [INFO] Jika Chrome mengalami kendala debug port, mencoba via Microsoft Edge...
    call flutter run -d edge
)
echo.
pause
