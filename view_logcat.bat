@echo off
title Vintech School - Android Real-Time Logcat (Timestamp ^& ms)
color 0E
cd /d "%~dp0"

echo =======================================================================
echo   VINTECH SCHOOL - ANDROID LOGCAT (WAKTU ^& MILIDETIK ms)
echo   Format: [Bulan-Hari Jam:Menit:Detik.Milidetik] [PID] [TID] [LEVEL/TAG]
echo =======================================================================
echo.
echo Menghubungkan ke emulator Android (emulator-5554)...
echo Tekan Ctrl+C untuk berhenti melihat log.
echo.

"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 logcat -c
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 logcat -v threadtime
pause
