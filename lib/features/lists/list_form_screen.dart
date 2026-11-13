import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/models/models.dart';
import 'package:mis_listas/core/utils/utils.dart';
import 'package:mis_listas/core/widgets/widgets.dart';

class ListFormScreen extends StatefulWidget {
  final Lista? list;
  const ListFormScreen({super.key, this.list});
  @override
  State<ListFormScreen> createState() => _ListFormScreenState();
}

class _ListFormScreenState extends State<ListFormScreen> {
  final nameC = TextEditingController();
  final emojiC = TextEditingController();
  final budgetC = TextEditingController();
  int color = kPalette.first;
  String? cover;

  @override
  void initState() {
    super.initState();
    final l = widget.list;
    if (l != null) {
      nameC.text = l.name;
      emojiC.text = l.emoji;
      color = l.color;
      cover = l.cover;
      if (l.budget != null) budgetC.text = shortNum(l.budget!);
    } else {
      emojiC.text = '📝';
    }
  }

  Future<void> pickCover() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final path = files.single.path;
    if (path == null) return;
    final saved = await persistFile(path);
    setState(() => cover = saved);
  }

  Future<void> save() async {
    if (nameC.text.trim().isEmpty) {
      snack(context, 'Ponle un nombre a la lista');
      return;
    }
    final l = widget.list ?? Lista(name: '');
    l.name = nameC.text.trim();
    l.emoji = emojiC.text.trim().isEmpty ? '📝' : emojiC.text.trim();
    l.color = color;
    l.cover = cover;
    l.budget = double.tryParse(budgetC.text.replaceAll(',', '.'));
    await Repo.instance.saveList(l);
    if (mounted) Navigator.pop(context, l);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list == null ? 'Nueva lista' : 'Editar lista'),
        actions: [
          TextButton.icon(
              onPressed: save,
              icon: const Icon(Icons.check),
              label: const Text('Guardar')),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: Color(color).withAlpha(60),
            borderRadius: BorderRadius.circular(16),
            image: cover != null && File(cover!).existsSync()
                ? DecorationImage(
                    image: FileImage(File(cover!)), fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(emojiC.text.isEmpty ? '📝' : emojiC.text,
              style: const TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 8),
        Row(children: [
          OutlinedButton.icon(
              onPressed: pickCover,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Portada')),
          if (cover != null)
            TextButton(
                onPressed: () => setState(() => cover = null),
                child: const Text('Quitar')),
        ]),
        const SizedBox(height: 16),
        TextField(
            controller: nameC,
            textCapitalization: TextCapitalization.sentences,
            decoration: dec('Nombre de la lista', icon: Icons.title)),
        const SizedBox(height: 12),
        TextField(
            controller: budgetC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: dec('Presupuesto (opcional)', icon: Icons.euro)),
        const SizedBox(height: 20),
        Text('Color', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in kPalette)
            GestureDetector(
              onTap: () => setState(() => color = c),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: color == c ? Colors.black87 : Colors.transparent,
                      width: 3),
                ),
                child: color == c
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
        ]),
        const SizedBox(height: 20),
        Text('Emoji / icono', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final e in kEmojis)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => emojiC.text = e),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: emojiC.text == e ? Color(color).withAlpha(60) : null,
                ),
                child: Text(e, style: const TextStyle(fontSize: 26)),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: emojiC,
          onChanged: (_) => setState(() {}),
          decoration: dec('O escribe/pega tu propio emoji',
              icon: Icons.emoji_emotions_outlined),
        ),
      ]),
    );
  }
}
