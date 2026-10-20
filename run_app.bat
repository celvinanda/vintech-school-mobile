@echo off
title Vintech School Mobile - Launcher
color 0B
cd /d "%~dp0"

:: Cek apakah Windows Terminal (wt.exe) tersedia
where wt.exe >nul 2>&1
if not errorlevel 1 (
    set "USE_WT=1"
) else (
    set "USE_WT=0"
)

:menu
cls
echo ===================================================
echo     VINTECH SCHOOL - MOBILE APP (ANDROID ^& iOS)
echo ===================================================
echo.
echo Pilihan Perangkat / Aksi:
echo [0] Jalankan Android Emulator (vintech_pixel_light - Hemat RAM)
echo [1] Jalankan Aplikasi di Chrome (Tab Terminal Baru)
echo [2] Jalankan Aplikasi di Android Emulator (Tab Terminal Baru)
echo [3] Buka Logcat Android Real-Time (Tab Baru + Waktu ^& Milidetik ms)
echo [4] Cek Perangkat Terhubung (flutter devices)
echo [5] Jalankan Unit ^& Widget Test (flutter test)
echo [6] Keluar
echo.
set /p opt="Pilih opsi (0-6): "

if "%opt%"=="0" (
    echo.
    echo Menjalankan emulator Android hemat RAM...
    set ANDROID_AVD_HOME=D:\Android\avd
    start "Vintech Android Emulator" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd vintech_pixel_light -netdelay none -netspeed full
    echo Emulator telah dibuka di jendela emulator Android!
    echo.
    pause
    goto menu
)
if "%opt%"=="1" (
    echo.
    echo Membuka Flutter Web di tab terminal baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Vintech Web (Chrome)" -d "%~dp0" cmd /k "flutter run -d chrome"
    ) else (
        start "Vintech Web (Chrome)" cmd /k "flutter run -d chrome"
    )
    echo Tab baru telah dibuat di Windows Terminal!
    pause
    goto menu
)
if "%opt%"=="2" (
    echo.
    echo Membuka Flutter App Runner di tab terminal baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Vintech App Runner" -d "%~dp0" cmd /k "flutter run -d emulator-5554"
    ) else (
        start "Vintech App Runner" cmd /k "flutter run -d emulator-5554"
    )
    echo Tab baru telah dibuat di Windows Terminal yang sama!
    echo.
    pause
    goto menu
)
if "%opt%"=="3" (
    echo.
    echo Membuka Logcat Android real-time dengan waktu dan milidetik di tab baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Android Logcat (ms)" -d "%~dp0" cmd /k "call view_logcat.bat"
    ) else (
        start "Android Logcat (ms)" cmd /k "call view_logcat.bat"
    )
    echo Tab Logcat telah dibuka di Windows Terminal yang sama!
    echo.
    pause
    goto menu
)
if "%opt%"=="4" (
    echo.
    call flutter devices
    echo.
    pause
    goto menu
)
if "%opt%"=="5" (
    echo.
    call flutter test
    echo.
    pause
    goto menu
)
if "%opt%"=="6" (
    exit /b
)

echo Pilihan tidak valid. Silakan coba lagi.
pause
goto menu
