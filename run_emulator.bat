@echo off
title Vintech School - Android Emulator Launcher (Low-Spec Optimized)
color 0A
echo =================================================================
echo   VINTECH SCHOOL - ANDROID EMULATOR (vintech_pixel_light)
echo   Optimasi: RAM 1.5 GB ^| Host GPU WHPX ^| Lokasi Disk D:\Android
echo =================================================================
echo.
echo Menjalankan emulator Android...
set ANDROID_AVD_HOME=D:\Android\avd
start "" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd vintech_pixel_light -netdelay none -netspeed full
echo.
echo Emulator sedang dibuka di jendela terpisah!
echo Anda dapat kembali ke VS Code / Terminal dan menjalankan:
echo   flutter run
echo.
pause
