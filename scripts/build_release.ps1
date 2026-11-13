# Genera los instaladores: APK para Android y carpeta Release para Windows.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
flutter build apk --release
flutter build windows --release
Write-Host "APK:     build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
Write-Host "Windows: build\windows\x64\runner\Release\" -ForegroundColor Green
