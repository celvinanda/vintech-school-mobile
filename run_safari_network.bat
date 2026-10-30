@echo off
title Vintech School Web Server (Safari / iPhone / Network)
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - WEB SERVER (UNTUK SAFARI / IPHONE / JARINGAN WI-FI)
echo =======================================================================
echo.
echo Mencari IP Address komputer di jaringan Wi-Fi lokal...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i /c:"IPv4 Address" /c:"Alamat IPv4"') do (
    set "MY_IP=%%a"
    goto :ip_found
)
:ip_found
set "MY_IP=%MY_IP: =%"

echo.
echo -----------------------------------------------------------------------
echo  LINK AKSES UNTUK SAFARI (iPhone / iPad / Mac di Wi-Fi yang sama):
echo  http://%MY_IP%:8080
echo -----------------------------------------------------------------------
echo.
echo Menjalankan Flutter Web Server pada host 0.0.0.0:8080...
echo.

call flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

pause
