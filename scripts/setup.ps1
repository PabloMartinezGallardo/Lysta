# Prepara el proyecto: genera android/ y windows/, instala dependencias y aplica los ajustes.
# Uso (desde cualquier sitio):  powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)   # raiz del proyecto

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: 'flutter' no esta en el PATH. Instala Flutter y reabre la terminal." -ForegroundColor Red
  exit 1
}

Write-Host ">> [1/4] Generando carpetas android/ y windows/ ..." -ForegroundColor Cyan
flutter create --platforms=android,windows --org com.mislistas --project-name mis_listas .
if (Test-Path "test") { Remove-Item -Recurse -Force "test" }

Write-Host ">> [2/4] Instalando dependencias ..." -ForegroundColor Cyan
flutter pub get

Write-Host ">> [3/4] Ajustando Android (permisos y minSdk) ..." -ForegroundColor Cyan
$manifest = "android/app/src/main/AndroidManifest.xml"
$t = Get-Content $manifest -Raw
if ($t -notmatch "RECORD_AUDIO") {
  $perm = '$1' + "`n    " + '<uses-permission android:name="android.permission.RECORD_AUDIO"/>'
  $t = $t -replace '(<manifest[^>]*>)', $perm
}
if ($t -notmatch 'android:scheme="https"') {
  if ($t -match '</queries>') {
    $q = '<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>' + "`n    </queries>"
    $t = $t -replace '</queries>', $q
  } else {
    $q = '<queries><intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent></queries>' + "`n    " + '<application'
    $t = $t -replace '<application', $q
  }
}
Set-Content $manifest $t -NoNewline

foreach ($f in @("android/app/build.gradle.kts", "android/app/build.gradle")) {
  if (Test-Path $f) {
    $g = Get-Content $f -Raw
    $g = $g -replace 'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 23'
    $g = $g -replace 'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 23'
    Set-Content $f $g -NoNewline
  }
}

Write-Host ">> [4/4] Analizando el codigo ..." -ForegroundColor Cyan
flutter analyze

Write-Host ""
Write-Host "Listo. Ejecuta:  flutter run -d windows   |   flutter run   (movil Android conectado)" -ForegroundColor Green
