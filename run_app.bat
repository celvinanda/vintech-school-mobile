@echo off
title Vintech School Mobile - Launcher
color 0B
echo ===================================================
echo     VINTECH SCHOOL - MOBILE APP (ANDROID & iOS)
echo ===================================================
echo.
echo Memilih target perangkat:
echo [1] Jalankan di Browser Chrome (Web Preview Cepat)
echo [2] Jalankan di Emulator Android / Perangkat Fisik
echo [3] Cek Perangkat Terhubung (flutter devices)
echo [4] Jalankan Unit & Widget Test (flutter test)
echo [5] Keluar
echo.
set /p opt="Pilih opsi (1-5): "

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
