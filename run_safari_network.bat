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
echo [1] Mode RELEASE KILAT (PILIHAN UTAMA - Sangat Cepat, Mulus, Anti-Blank)
echo     -^> Membuka langsung dalam 1-2 detik di Edge, Chrome, Safari, dan Ponsel.
echo [2] Mode DEBUG Developer (Khusus Developer dengan Chrome Dart Debugger)
echo     -^> PERHATIAN: Membutuhkan Chrome Debugger. Jangan gunakan di Edge/Safari/HP
echo         karena akan tertahan (stuck blank putih) menunggu debugger.
echo [3] Build Ulang Web Release (Kompilasi kode terbaru sebelum dijalankan)
echo.
set "mode=1"
set /p mode="Pilih mode [1/2/3, default 1 (TEKAN ENTER LANGSUNG)]: "
if "%mode%"=="" set mode=1

if "%mode%"=="2" goto mode_debug
if "%mode%"=="3" goto mode_rebuild

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

:mode_debug
echo.
echo =======================================================================
echo [PERHATIAN MODE DEBUG]
echo Mode ini menjalankan Dart Web Debug Service (DWDS).
echo Jika dibuka di Microsoft Edge atau Safari tanpa ekstensi debugger Chrome,
echo halaman akan berhenti pada status 'Loading...' / blank putih.
echo Jika ingin melihat tampilan aplikasi secara normal, gunakan MODE 1.
echo =======================================================================
echo.
echo Menjalankan Flutter Web Server pada host 0.0.0.0:8080 (Mode Debug)...
echo.
call flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
goto end

:end
pause
