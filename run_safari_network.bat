@echo off
title Vintech School Web Server (Safari / iPhone / Network)
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - WEB SERVER (UNTUK SAFARI / IPHONE / JARINGAN WI-FI)
echo =======================================================================
echo.
echo Mendeteksi IP Address Wi-Fi lokal komputer...

for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq 'Wi-Fi' -or $_.InterfaceAlias -like 'Ethernet*' } | Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -notlike '172.*' } | Select-Object -First 1).IPAddress"`) do (
    set "MY_IP=%%i"
)

if "%MY_IP%"=="" (
    set "MY_IP=192.168.1.9"
)

echo.
echo =======================================================================
echo  LINK RESMI UNTUK SAFARI (iPhone / iPad / Mac di Wi-Fi yang sama):
echo.
echo  👉  http://%MY_IP%:8080
echo.
echo  (Jika membuka di browser laptop ini: http://localhost:8080)
echo =======================================================================
echo.
echo [INFO] Abaikan peringatan DWDS WebSocket jika muncul di terminal saat
echo        Safari terhubung. Itu hanya debugger Chrome yang tidak ada di Safari,
echo        aplikasi tetap berjalan 100%% normal di layar Safari Anda.
echo.
echo Menjalankan Flutter Web Server pada host 0.0.0.0:8080...
echo.

call flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

pause
