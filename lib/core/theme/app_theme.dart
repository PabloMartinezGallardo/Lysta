import 'package:flutter/material.dart';
import 'package:mis_listas/core/database/app_database.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode mode = ThemeMode.light;

  Future<void> load() async {
    final v = await Repo.instance.getSetting('theme');
    mode = v == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool dark) async {
    mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await Repo.instance.setSetting('theme', dark ? 'dark' : 'light');
  }
}

ThemeData buildTheme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE91E63),
        brightness: b,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
