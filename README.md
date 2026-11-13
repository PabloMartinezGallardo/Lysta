<div align="center">

# 📝 Mis listas

**Listas personalizadas de cualquier tema, con precios, presupuesto y estadísticas.**

![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-local-003B57?logo=sqlite&logoColor=white)
![Android](https://img.shields.io/badge/Android-6.0%2B-3DDC84?logo=android&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white)

</div>

---

## ✨ ¿Qué es?

**Mis listas** es una aplicación multiplataforma (Android y Windows) para crear listas
totalmente personalizadas: la compra, la maleta del viaje, los objetivos del año, una rutina
de ejercicios, un inventario… lo que se te ocurra.

Cada elemento puede llevar precio y cantidad, así que la app **suma el gasto en tiempo real** y
te avisa si te pasas del presupuesto o te sobra dinero. Todo se guarda en una base de datos
**SQLite local**: funciona sin internet y tus datos no salen de tu dispositivo.

## 🧩 Funcionalidades

### Listas
- Crea listas de cualquier tema y reordénalas **arrastrando y soltando**.
- Personalízalas con **color, emoji/icono y portada** (imagen).
- Tres **vistas** por lista: **clásica**, **Kanban** (Por hacer · En curso · Hecho) y **calendario**.
  La app recuerda la vista elegida en cada lista.

### Elementos flexibles
Nueve tipos de elemento para guardar lo que necesites:

| Tipo | Para qué sirve |
|---|---|
| 📝 Texto | Notas y descripciones |
| ☑️ Casilla | Checklists |
| 🖼️ Imagen | Fotos de referencia |
| 🔗 Enlace | Webs y productos (se abren con un toque) |
| 📅 Fecha | Fechas límite o eventos |
| ⏰ Hora | Recordatorios con hora |
| 🎙️ Nota de voz | Graba y reproduce audios |
| 📎 Archivo | Adjunta cualquier documento |
| 🔢 Etiqueta numérica | Tallas, series, prioridades… |

Además, todos los elementos admiten **precio, cantidad, categoría, favorito, estado y fecha/hora**.
Se pueden reordenar arrastrando.

### 💶 Presupuesto
- Define un presupuesto por lista.
- Consulta el **total**, lo ya **comprado** y una barra de progreso.
- Mensaje claro: *«Te sobran X €»* o *«Te pasas del presupuesto por X €»*.

### 📊 Estadísticas
- Gasto por categoría (gráfico circular).
- Lo que más repites en tus listas.
- Tus favoritos ❤️ y resumen global (listas, elementos, gasto total).

### 📋 Plantillas
- Cinco plantillas listas para usar: **Supermercado, Maleta de viaje, Objetivos del año,
  Rutina de ejercicios e Inventario**.
- **Guarda cualquier lista como plantilla** y reutilízala cuando quieras.

### 🎨 Interfaz
- **Modo claro y oscuro** (se recuerda tu elección).
- Diseño Material 3 en español.


## 🚀 Instalación (usuarios)

Descarga la última versión desde la sección [**Releases**](../../releases):

- **Android:** descarga el `.apk`, ábrelo en el móvil y permite la instalación desde «orígenes desconocidos».
- **Windows:** descarga el `.zip`, descomprímelo y ejecuta `mis_listas.exe`.

## 🛠️ Desarrollo

### Requisitos
- [Flutter](https://docs.flutter.dev/get-started/install) 3.24 o superior
- **Android:** Android Studio + Android SDK (`flutter doctor --android-licenses`)
- **Windows:** Visual Studio 2022 con «Desarrollo de escritorio con C++» y el **Modo desarrollador**
  activado (`start ms-settings:developers`)

### Puesta en marcha
```bash
git clone <url-del-repositorio>
cd mis_listas
```
Doble clic en **`setup.bat`** (o `powershell -ExecutionPolicy Bypass -File scripts\setup.ps1`).
Este script genera las carpetas `android/` y `windows/`, instala dependencias, añade los permisos
de micrófono y enlaces y fija `minSdk 23`.

```bash
flutter doctor
flutter run -d windows     # Windows
flutter run                # Android conectado por USB
```

### Generar instaladores
```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1
```
- APK: `build\app\outputs\flutter-apk\app-release.apk`
- Windows: `build\windows\x64\runner\Release\`

### Estructura
```
lib/
├── main.dart · app.dart
├── core/        # base de datos, modelos, tema, utilidades y widgets compartidos
└── features/    # home · lists · items · stats · templates
```
Más detalle en [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

## 🧱 Tecnologías

| Función | Paquete |
|---|---|
| Base de datos | `sqflite` (Android) · `sqflite_common_ffi` (Windows) |
| Ficheros y rutas | `path_provider`, `path`, `file_picker`, `open_filex` |
| Audio | `record`, `audioplayers` |
| Calendario y gráficos | `table_calendar`, `fl_chart` |
| Enlaces y formato | `url_launcher`, `intl` |

## 🩺 Solución de problemas

| Problema | Solución |
|---|---|
| `flutter` no se reconoce | Añade `flutter\bin` al PATH y reabre la terminal |
| `Building with plugins requires symlink support` | Activa el Modo desarrollador de Windows |
| Error en `pub get` | `flutter pub upgrade --major-versions` |
| Falta `sqlite3.dll` en Windows | `flutter pub add sqlite3_flutter_libs` y `flutter clean` |
| `minSdkVersion 21 cannot be smaller than 23` | Pon `minSdk = 23` en `android/app/build.gradle(.kts)` |
| No graba audio en Android | Concede el permiso de micrófono en Ajustes |
| Errores raros tras cambios | `flutter clean` y `flutter pub get` |

## 🔒 Privacidad
Todos los datos (base de datos, imágenes, audios y archivos) se guardan **solo en el dispositivo**.
La app no envía información a ningún servidor.