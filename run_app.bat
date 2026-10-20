@echo off
title Vintech School Mobile - Launcher
color 0B
echo ===================================================
echo     VINTECH SCHOOL - MOBILE APP (ANDROID & iOS)
echo ===================================================
echo.
echo Pilihan Perangkat / Aksi:
echo [0] Jalankan Android Emulator (vintech_pixel_light - Hemat RAM)
echo [1] Jalankan Aplikasi di Chrome (Web Preview Cepat)
echo [2] Jalankan Aplikasi di Android Emulator / HP Fisik (flutter run)
echo [3] Cek Perangkat Terhubung (flutter devices)
echo [4] Jalankan Unit & Widget Test (flutter test)
echo [5] Keluar
echo.
set /p opt="Pilih opsi (0-5): "

if "%opt%"=="0" (
    echo.
    echo Menjalankan emulator Android hemat RAM...
    set ANDROID_AVD_HOME=D:\Android\avd
    start "" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd vintech_pixel_light -netdelay none -netspeed full
    echo Emulator telah dibuka di jendela baru!
    pause
)
if "%opt%"=="1" (
    echo.
    echo Menjalankan di Chrome...
    flutter run -d chrome
)
if "%opt%"=="2" (
    echo.
    echo Menjalankan di Android/iOS...
    flutter run
)
if "%opt%"=="3" (
    echo.
    flutter devices
    pause
)
if "%opt%"=="4" (
    echo.
    flutter test
    pause
)
if "%opt%"=="5" (
    exit
)
