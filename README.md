# Mis listas 💖

App Flutter (Android + Windows) de listas personalizadas con precios, presupuesto,
estadísticas, plantillas y vistas Lista / Kanban / Calendario. Datos en SQLite local.
Estructura detallada en `docs/ARQUITECTURA.md`.

## Requisitos
- Flutter 3.24+  →  https://docs.flutter.dev/get-started/install
- Android: Android Studio + SDK  (`flutter doctor --android-licenses`)
- Windows: Visual Studio 2022 con «Desarrollo de escritorio con C++» y **Modo desarrollador**
  activado (`start ms-settings:developers`)

## Preparar (una sola vez)
Doble clic en **`setup.bat`** (o `powershell -ExecutionPolicy Bypass -File scripts\setup.ps1`).
Genera `android/` y `windows/`, instala dependencias, añade permiso de micrófono/enlaces y
fija minSdk 23.

## Ejecutar
    flutter doctor
    flutter run -d windows      # Windows
    flutter run                 # Android conectado por USB

## Instaladores
    powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1
APK: `build\app\outputs\flutter-apk\app-release.apk` · Windows: `build\windows\x64\runner\Release\`

## Si algo falla
| Problema | Solución |
|---|---|
| `flutter` no se reconoce | Añade `flutter\bin` al PATH y reabre la terminal |
| `Building with plugins requires symlink support` | Activa el Modo desarrollador de Windows |
| Error en `pub get` | `flutter pub upgrade --major-versions` |
| Falta `sqlite3.dll` en Windows | `flutter pub add sqlite3_flutter_libs` y `flutter clean` |
| `minSdkVersion 21 cannot be smaller than 23` | Pon `minSdk = 23` en `android/app/build.gradle(.kts)` |
| No graba audio en Android | Concede el permiso de micrófono en Ajustes |
| Errores raros tras cambios | `flutter clean` y `flutter pub get` |
| `flutter analyze` muestra avisos | Los avisos no impiden compilar; los errores sí: envíamelos |
