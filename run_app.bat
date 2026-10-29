@echo off
setlocal
cd /d "%~dp0"

:: Cek apakah Windows Terminal (wt.exe) tersedia
where wt.exe >nul 2>&1
if not errorlevel 1 (
    set "USE_WT=1"
) else (
    set "USE_WT=0"
)

:: Jika Windows Terminal tersedia tapi script dijalankan di jendela conhost biasa,
:: buka otomatis di dalam Windows Terminal agar menu dan runner selalu dalam satu jendela bertab.
if "%USE_WT%"=="1" (
    if "%WT_SESSION%"=="" (
        start wt.exe --title "Vintech School Mobile - Launcher" -d "%CD%" cmd.exe /k ""%~f0""
        exit /b
    )
)

:menu
cls
echo ===================================================
echo     VINTECH SCHOOL - MOBILE APP [ANDROID ^& iOS]
echo ===================================================
echo.
echo Pilihan Perangkat / Aksi:
echo [0] Jalankan Android Emulator Super Light [1GB RAM]
echo [1] Jalankan Aplikasi di Chrome Web [Clean Profile]
echo [2] Jalankan Aplikasi di Android Emulator
echo [3] Jalankan Aplikasi di Windows Desktop [Instan, Hemat RAM ~100MB]
echo [4] Buka Logcat Android Real-Time [ms]
echo [5] Cek Perangkat Terhubung [flutter devices]
echo [6] Jalankan Unit ^& Widget Test [flutter test]
echo [7] Keluar
echo.
set /p opt="Pilih opsi [0-7]: "

if "%opt%"=="0" (
    echo.
    echo Menjalankan emulator Android super ringan vintech_super_light...
    set ANDROID_AVD_HOME=D:\Android\avd
    start "Vintech Super Light Emulator" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd vintech_super_light -netdelay none -netspeed full
    echo Emulator telah dibuka di jendela borderless!
    echo.
    pause
    goto menu
)
if "%opt%"=="1" (
    echo.
    echo Membuka Flutter Web di tab terminal baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Vintech Web Chrome" -d "%CD%" cmd.exe /k run_web.bat
    ) else (
        start "Vintech Web Chrome" cmd.exe /k run_web.bat
    )
    echo Tab baru telah dibuat di Windows Terminal!
    pause
    goto menu
)
if "%opt%"=="2" (
    echo.
    echo Membuka Flutter App Runner di tab terminal baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Vintech App Runner" -d "%CD%" cmd.exe /k run_android.bat
    ) else (
        start "Vintech App Runner" cmd.exe /k run_android.bat
    )
    echo Tab baru telah dibuat di Windows Terminal yang sama!
    echo.
    pause
    goto menu
)
if "%opt%"=="3" (
    echo.
    echo Membuka Flutter Windows Desktop di tab terminal baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Vintech Windows App" -d "%CD%" cmd.exe /k run_windows.bat
    ) else (
        start "Vintech Windows App" cmd.exe /k run_windows.bat
    )
    echo Aplikasi desktop native sedang dijalankan!
    echo.
    pause
    goto menu
)
if "%opt%"=="4" (
    echo.
    echo Membuka Logcat Android real-time di tab baru...
    if "%USE_WT%"=="1" (
        wt.exe -w 0 nt --title "Android Logcat ms" -d "%CD%" cmd.exe /k view_logcat.bat
    ) else (
        start "Android Logcat ms" cmd.exe /k view_logcat.bat
    )
    echo Tab Logcat telah dibuka di Windows Terminal yang sama!
    echo.
    pause
    goto menu
)
if "%opt%"=="5" (
    echo.
    call flutter devices
    echo.
    pause
    goto menu
)
if "%opt%"=="6" (
    echo.
    call flutter test
    echo.
    pause
    goto menu
)
if "%opt%"=="7" (
    exit /b
)

echo Pilihan tidak valid. Silakan coba lagi.
pause
goto menu
