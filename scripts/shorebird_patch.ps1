<#
=======================================================================
  VINTECH SCHOOL - SHOREBIRD OTA CODE PATCH DEPLOYER
=======================================================================
Gunakan skrip ini setiap kali ada perubahan kode Dart, UI, atau perbaikan bug.
Patch akan dikirim secara Over-The-Air (OTA) ke seluruh HP siswa & guru
tanpa perlu membagikan file APK baru!
#>

Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "  VINTECH SCHOOL - SHOREBIRD OTA CODE PATCH DEPLOYER" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan

# 1. Cek ketersediaan Shorebird CLI
if (-not (Get-Command shorebird -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Shorebird CLI belum terdeteksi di sistem." -ForegroundColor Yellow
    Write-Host "    Silakan install Shorebird via PowerShell:" -ForegroundColor White
    Write-Host "    Set-ExecutionPolicy RemoteSigned -scope CurrentUser" -ForegroundColor Gray
    Write-Host "    iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex" -ForegroundColor Gray
    exit 1
}

# 2. Jalankan patch bytecode
Write-Host "[*] Membangun dan mengirim patch kode OTA ke cloud Shorebird..." -ForegroundColor Green
shorebird patch android

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "✓ Patch kode OTA berhasil dikirim ke server Shorebird!" -ForegroundColor Green
Write-Host "  Siswa & guru akan otomatis menerima perubahan kode saat membuka aplikasi" -ForegroundColor White
Write-Host "  atau saat mengetuk 'Periksa Pembaruan OTA' di halaman Pengaturan." -ForegroundColor White
Write-Host "=======================================================================" -ForegroundColor Cyan
