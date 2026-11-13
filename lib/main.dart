import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_listas/app.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/theme/app_theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // En Windows (y escritorio) SQLite funciona vía FFI; en Android usa sqflite.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await initializeDateFormatting('es_ES');
  await Repo.instance.init();
  await ThemeController.instance.load();
  runApp(const MyApp());
}
