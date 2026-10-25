<#
=======================================================================
  VINTECH SCHOOL - SHOREBIRD BASE RELEASE GENERATOR
=======================================================================
Gunakan skrip ini saat merilis versi dasar (Base Release APK) pertama kali
atau jika terdapat penambahan plugin native / izin AndroidManifest baru.
#>

Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "  VINTECH SCHOOL - SHOREBIRD BASE RELEASE GENERATOR" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan

# 1. Cek ketersediaan Shorebird CLI
if (-not (Get-Command shorebird -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Shorebird CLI belum terdeteksi di sistem." -ForegroundColor Yellow
    Write-Host "    Silakan install Shorebird via PowerShell:" -ForegroundColor White
    Write-Host "    Set-ExecutionPolicy RemoteSigned -scope CurrentUser" -ForegroundColor Gray
    Write-Host "    iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex" -ForegroundColor Gray
    exit 1
}

# 2. Verifikasi login shorebird
Write-Host "[*] Memeriksa akun Shorebird..." -ForegroundColor Green
shorebird doctor

# 3. Jalankan rilis Android APK
Write-Host "[*] Membangun Base Release Android APK dengan Shorebird Engine..." -ForegroundColor Green
shorebird release android --artifact apk

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "✓ Base Release APK berhasil dibangun!" -ForegroundColor Green
Write-Host "  Lokasi APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host "  Bagikan APK ini ke siswa / guru untuk instalasi pertama." -ForegroundColor White
Write-Host "  Untuk update kode selanjutnya (UI/Bugfix), cukup jalankan: .\scripts\shorebird_patch.ps1" -ForegroundColor Yellow
Write-Host "=======================================================================" -ForegroundColor Cyan
