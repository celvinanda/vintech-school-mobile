@echo off
title Vintech Mobile - Build & Install Android
color 0B
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - BUILD & INSTALL APK KE ANDROID
echo =======================================================================
echo.

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "DEVICE_ID="
set "APK=build\app\outputs\flutter-apk\app-debug.apk"
set "DART_VM_OPTIONS=--old_gen_heap_size=2048"

:: 1. Deteksi ADB
if not exist "%ADB%" (
    echo [ERROR] adb.exe tidak ditemukan di %ADB%
    echo Pastikan Android SDK Platform-Tools terpasang.
    pause
    exit /b 1
)

:: 2. Deteksi perangkat aktif via ADB
for /f "skip=1 tokens=1,2" %%A in ('"%ADB%" devices') do (
    if "%%B"=="device" (
        set "DEVICE_ID=%%A"
        goto :device_found
    )
)

echo [PERINGATAN] Tidak ada perangkat Android terdeteksi!
echo Pastikan HP terhubung kabel USB dengan mode 'USB Debugging' aktif,
echo atau nyalakan Android Emulator terlebih dahulu.
echo.
pause
exit /b 1

:device_found
echo [TARGET] Perangkat Android terdeteksi: %DEVICE_ID%
echo.

:: Peringatan khusus HP Xiaomi / MIUI
echo %DEVICE_ID% | findstr /i "emulator" >nul
if errorlevel 1 (
    echo [PENTING HP XIAOMI/MIUI]
    echo Jika muncul pop-up 'Install via USB' pada layar HP Anda,
    echo SEGERA tekan tombol 'INSTALL' / 'IZINKAN' di layar HP!
    echo.
)

:: 3. Jalankan Kompilasi Build APK Debug
echo [1/3] Mengompilasi APK Android (flutter build apk --debug)...
call flutter build apk --debug
if errorlevel 1 (
    echo.
    echo [GAGAL] Terjadi kesalahan saat build APK. Silakan periksa pesan di atas.
    pause
    exit /b 1
)

if not exist "%APK%" (
    echo.
    echo [GAGAL] File APK tidak ditemukan di %APK%
    pause
    exit /b 1
)

:: 4. Pasang (Install) APK ke Perangkat
echo.
echo [2/3] Memasang APK ke perangkat %DEVICE_ID%...
"%ADB%" -s %DEVICE_ID% install -r "%APK%"
if errorlevel 1 (
    echo.
    echo [GAGAL] Gagal memasang APK ke perangkat.
    echo Pastikan opsi 'Install via USB' diizinkan di Pengaturan Pengembang HP Anda.
    pause
    exit /b 1
)

:: 5. Jalankan Aplikasi di Perangkat
echo.
echo [3/3] Meluncurkan aplikasi di layar %DEVICE_ID%...
"%ADB%" -s %DEVICE_ID% shell monkey -p com.vintech.school.vintech_school_mobile -c android.intent.category.LAUNCHER 1 >nul 2>&1

echo.
echo =======================================================================
echo   SUKSES: Aplikasi Vintech School berhasil di-build, di-install,
echo           dan diluncurkan di perangkat Android Anda!
echo =======================================================================
echo.
pause
