@echo off
title Vintech School Web Server (Ponsel Safari / Chrome / Wi-Fi Network)
color 0A
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - WEB SERVER (UNTUK PONSEL / SAFARI / CHROME / WI-FI)
echo =======================================================================
echo.
echo Mendeteksi IP Address Wi-Fi lokal komputer...

for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq 'Wi-Fi' -or $_.InterfaceAlias -like 'Ethernet*' } | Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -notlike '172.*' } | Select-Object -First 1).IPAddress"`) do (
    set "MY_IP=%%i"
)

if "%MY_IP%"=="" (
    set "MY_IP=192.168.1.9"
)

:: Membersihkan proses zombie di port 8080 jika ada
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo =======================================================================
echo  LINK RESMI AKSES DARI PONSEL (iPhone / Android / Mac di Wi-Fi):
echo.
echo  👉  http://%MY_IP%:8080
echo.
echo  (Jika dibuka di browser laptop ini: http://localhost:8080)
echo =======================================================================
echo.
echo Pilih Mode Web Server:
echo [1] Mode RELEASE KILAT (PILIHAN UTAMA - Cukup TEKAN ENTER)
echo     -^> Buka langsung dalam 1-2 detik di Ponsel (Safari/Chrome) & Laptop (Edge/Chrome).
echo     -^> Sangat cepat, hemat RAM, anti-blank putih, 1 file teroptimasi.
echo.
echo [2] Mode DEBUG Laptop (Microsoft Edge dengan Hot-Restart)
echo     -^> Otomatis membuka Edge laptop dengan debugger aktif (tidak akan blank putih).
echo.
echo [3] Mode DEBUG Laptop (Google Chrome dengan Hot-Restart)
echo     -^> Otomatis membuka Chrome laptop dengan debugger aktif.
echo.
echo [4] Build Ulang Web Release (Kompilasi kode terbaru lalu jalankan)
echo.
set "mode=1"
set /p mode="Pilih mode [1/2/3/4, default 1 (LANGSUNG TEKAN ENTER)]: "
if "%mode%"=="" set mode=1

if "%mode%"=="2" goto mode_debug_edge
if "%mode%"=="3" goto mode_debug_chrome
if "%mode%"=="4" goto mode_rebuild

:mode_release
echo.
if not exist "build\web\index.html" (
    echo [INFO] Bundle Web Release belum ditemukan. Melakukan kompilasi pertama kali...
    call flutter build web --release
)
echo [OK] Menjalankan High-Speed Web Server pada http://%MY_IP%:8080 ...
echo [TIPS] Di browser ponsel Chrome/Safari atau Edge laptop, buka: http://%MY_IP%:8080
echo Tekan Ctrl+C untuk menghentikan server.
echo.
python -m http.server 8080 --bind 0.0.0.0 --directory build\web
goto end

:mode_rebuild
echo.
echo [INFO] Membangun ulang bundle Web Release dengan kode terbaru...
call flutter build web --release
echo [OK] Kompilasi selesai! Menjalankan High-Speed Web Server...
python -m http.server 8080 --bind 0.0.0.0 --directory build\web
goto end

:mode_debug_edge
echo.
echo [INFO] Menjalankan Flutter Web pada Microsoft Edge (Mode Debug)...
call flutter run -d edge --web-hostname 0.0.0.0 --web-port 8080
goto end

:mode_debug_chrome
echo.
echo [INFO] Menjalankan Flutter Web pada Google Chrome (Mode Debug)...
call flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
goto end

:end
pause
