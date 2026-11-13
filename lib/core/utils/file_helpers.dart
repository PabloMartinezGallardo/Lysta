import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/utils/ui_helpers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

/// Copia un archivo a la carpeta propia de la app para que no se pierda.
Future<String> persistFile(String src) async {
  if (p.isWithin(Repo.instance.attachments.path, src)) return src;
  final dest = p.join(Repo.instance.attachments.path,
      '${DateTime.now().millisecondsSinceEpoch}_${p.basename(src)}');
  await File(src).copy(dest);
  return dest;
}

Future<void> openAttachment(BuildContext c, String path) async {
  try {
    if (Platform.isAndroid) {
      final r = await OpenFilex.open(path);
      if (r.type != ResultType.done) throw Exception(r.message);
    } else {
      final ok = await launchUrl(Uri.file(path));
      if (!ok) throw Exception('no');
    }
  } catch (_) {
    if (c.mounted) snack(c, 'No se pudo abrir el archivo');
  }
}

Future<void> openLink(BuildContext c, String url) async {
  var u = url.trim();
  if (u.isEmpty) return;
  if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'https://$u';
  try {
    final ok = await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
    if (!ok && c.mounted) snack(c, 'No se pudo abrir el enlace');
  } catch (_) {
    if (c.mounted) snack(c, 'Enlace no válido');
  }
}

