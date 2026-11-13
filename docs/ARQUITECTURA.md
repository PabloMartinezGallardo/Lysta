# Arquitectura

    lib/
    ├── main.dart                  Arranque: SQLite (ffi en Windows), idioma, tema
    ├── app.dart                   MaterialApp (tema claro/oscuro, localización es_ES)
    ├── core/                      Código compartido por todas las pantallas
    │   ├── database/app_database.dart   Esquema SQLite y todas las consultas (Repo)
    │   ├── models/models.dart           Lista, Item, tipos de elemento, plantillas
    │   ├── theme/app_theme.dart         ThemeData y controlador claro/oscuro
    │   ├── utils/                       format (dinero/fechas), ui_helpers (colores, emojis,
    │   │                                decoración), file_helpers (adjuntos, enlaces)
    │   └── widgets/                     BudgetCard (presupuesto), PlayButton (notas de voz)
    └── features/                  Una carpeta por funcionalidad
        ├── home/                  Pantalla principal (listas reordenables)
        ├── lists/                 Detalle de lista (Lista/Kanban/Calendario) y formulario
        ├── items/                 Formulario de elementos (9 tipos)
        ├── stats/                 Estadísticas
        └── templates/             Plantillas predefinidas y propias

    scripts/                       setup.ps1 (prepara el proyecto), build_release.ps1
    android/  windows/             Se generan con setup.bat (flutter create)

Para añadir una función nueva: crea `lib/features/<nombre>/` con su pantalla y,
si necesita datos, añade las consultas a `core/database/app_database.dart`.
