@echo off
title Vintech School Mobile - Launcher
color 0B
cd /d "%~dp0"

:menu
cls
echo ===================================================
echo     VINTECH SCHOOL - MOBILE APP (ANDROID ^& iOS)
echo ===================================================
echo.
echo Pilihan Perangkat / Aksi:
echo [0] Jalankan Android Emulator (vintech_pixel_light - Hemat RAM)
echo [1] Jalankan Aplikasi di Chrome (Web Preview Cepat)
echo [2] Jalankan Aplikasi di Android Emulator (Jendela / Tab Baru)
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
    echo Emulator telah dibuka di jendela baru!
    echo.
    pause
    goto menu
)
if "%opt%"=="1" (
    echo.
    echo Menjalankan di Chrome...
    start "Vintech School Web" cmd /c "flutter run -d chrome & pause"
    echo Aplikasi Chrome dibuka di tab/jendela baru!
    pause
    goto menu
)
if "%opt%"=="2" (
    echo.
    echo Menjalankan aplikasi di emulator Android pada jendela baru...
    start "Vintech Mobile App Runner" cmd /c "flutter run -d emulator-5554 & pause"
    echo Runner telah dibuka di jendela/tab baru terpisah dari menu ini!
    echo.
    pause
    goto menu
)
if "%opt%"=="3" (
    echo.
    echo Membuka Logcat Android real-time dengan waktu dan milidetik...
    start "Vintech Android Logcat" cmd /c "call view_logcat.bat"
    echo Logcat telah dibuka di jendela/tab baru!
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
