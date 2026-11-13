import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/models/models.dart';
import 'package:mis_listas/core/utils/utils.dart';
import 'package:mis_listas/core/widgets/widgets.dart';

class ItemFormScreen extends StatefulWidget {
  final int listId;
  final Item? item;
  const ItemFormScreen({super.key, required this.listId, this.item});
  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final titleC = TextEditingController();
  final valueC = TextEditingController();
  final priceC = TextEditingController();
  final catC = TextEditingController();
  final tagC = TextEditingController();
  final _rec = AudioRecorder();

  String type = 'text';
  String status = 'todo';
  String? path; // imagen / archivo / audio
  int qty = 1;
  bool fav = false;
  bool recording = false;
  DateTime? date;
  TimeOfDay? time;
  List<String> cats = [];

  bool get isPath => type == 'image' || type == 'file' || type == 'voice';

  @override
  void initState() {
    super.initState();
    Repo.instance.categories().then((c) {
      if (mounted) setState(() => cats = c);
    });
    final it = widget.item;
    if (it != null) {
      titleC.text = it.title;
      type = it.type;
      status = it.status;
      qty = it.qty;
      fav = it.fav;
      catC.text = it.category;
      if (it.price > 0) priceC.text = shortNum(it.price);
      if (it.numTag != null) tagC.text = shortNum(it.numTag!);
      if (isPath) {
        path = it.value.isEmpty ? null : it.value;
      } else {
        valueC.text = it.value;
      }
      final d = it.dueDate;
      if (d != null) {
        date = DateTime(d.year, d.month, d.day);
        if (it.hasTime) time = TimeOfDay.fromDateTime(d);
      }
    }
  }

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<void> pickFile(FileType t) async {
    final r = await FilePicker.pickFiles(type: t);
    if (r == null || r.isEmpty) return;
    final src = r.single.path;
    if (src == null) return;
    final saved = await persistFile(src);
    setState(() => path = saved);
  }

  Future<void> toggleRec() async {
    if (recording) {
      final f = await _rec.stop();
      setState(() {
        recording = false;
        if (f != null) path = f;
      });
      return;
    }
    if (!await _rec.hasPermission()) {
      if (mounted) snack(context, 'Permiso de micrófono denegado');
      return;
    }
    final win = Platform.isWindows;
    final file = p.join(Repo.instance.attachments.path,
        'voz_${DateTime.now().millisecondsSinceEpoch}.${win ? 'wav' : 'm4a'}');
    await _rec.start(
        RecordConfig(encoder: win ? AudioEncoder.wav : AudioEncoder.aacLc),
        path: file);
    setState(() => recording = true);
  }

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => date = d);
  }

  Future<void> pickTime() async {
    final t = await showTimePicker(
        context: context, initialTime: time ?? TimeOfDay.now());
    if (t != null) setState(() => time = t);
  }

  Future<void> save() async {
    if (titleC.text.trim().isEmpty) {
      snack(context, 'Escribe un título');
      return;
    }
    if (recording) await toggleRec();
    var d = date;
    if (d == null && time != null) d = DateTime.now();
    String? due;
    if (d != null) {
      due = DateFormat('yyyy-MM-dd').format(d);
      if (time != null) {
        due +=
            'T${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
      }
    }
    final it = widget.item ?? Item(listId: widget.listId, title: '');
    it
      ..title = titleC.text.trim()
      ..type = type
      ..value = isPath ? (path ?? '') : valueC.text.trim()
      ..price = double.tryParse(priceC.text.replaceAll(',', '.')) ?? 0
      ..qty = qty
      ..category = catC.text.trim()
      ..fav = fav
      ..status = status
      ..done = status == 'done'
      ..due = due
      ..numTag = type == 'number' ? double.tryParse(tagC.text.replaceAll(',', '.')) : null;
    await Repo.instance.saveItem(it);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar elemento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true) {
      await Repo.instance.deleteItem(widget.item!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget typeSpecific() {
    switch (type) {
      case 'text':
        return TextField(
            controller: valueC,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: dec('Nota / descripción', icon: Icons.notes));
      case 'link':
        return TextField(
            controller: valueC,
            keyboardType: TextInputType.url,
            decoration: dec('Enlace (https://...)', icon: Icons.link));
      case 'number':
        return Row(children: [
          Expanded(
              child: TextField(
                  controller: valueC,
                  decoration: dec('Etiqueta (ej. Talla, Series)', icon: Icons.label_outline))),
          const SizedBox(width: 12),
          SizedBox(
              width: 110,
              child: TextField(
                  controller: tagC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: dec('Número'))),
        ]);
      case 'image':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (path != null && File(path!).existsSync())
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(path!), height: 180, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
              onPressed: () => pickFile(FileType.image),
              icon: const Icon(Icons.image_outlined),
              label: Text(path == null ? 'Elegir imagen' : 'Cambiar imagen')),
        ]);
      case 'file':
        return Row(children: [
          OutlinedButton.icon(
              onPressed: () => pickFile(FileType.any),
              icon: const Icon(Icons.attach_file),
              label: Text(path == null ? 'Adjuntar archivo' : 'Cambiar archivo')),
          const SizedBox(width: 12),
          if (path != null) Expanded(child: Text(p.basename(path!), overflow: TextOverflow.ellipsis)),
        ]);
      case 'voice':
        return Row(children: [
          FilledButton.icon(
            style: recording ? FilledButton.styleFrom(backgroundColor: Colors.red) : null,
            onPressed: toggleRec,
            icon: Icon(recording ? Icons.stop : Icons.mic),
            label: Text(recording ? 'Parar grabación' : (path == null ? 'Grabar nota' : 'Grabar de nuevo')),
          ),
          if (path != null && !recording) PlayButton(path!),
        ]);
      default:
        return const SizedBox.shrink(); // check, date, time
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Nuevo elemento' : 'Editar elemento'),
        actions: [
          if (widget.item != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: delete),
          TextButton.icon(onPressed: save, icon: const Icon(Icons.check), label: const Text('Guardar')),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final t in kTypes)
            ChoiceChip(
              avatar: Icon(t.icon, size: 18),
              label: Text(t.label),
              selected: type == t.id,
              onSelected: (_) => setState(() {
                type = t.id;
                if (t.id == 'date' && date == null) date = DateTime.now();
                if (t.id == 'time' && time == null) time = TimeOfDay.now();
              }),
            ),
        ]),
        const SizedBox(height: 16),
        TextField(
            controller: titleC,
            autofocus: widget.item == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: dec('Título', icon: Icons.edit_outlined)),
        const SizedBox(height: 12),
        typeSpecific(),
        const SizedBox(height: 20),
        Text('Dinero', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: priceC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: dec('Precio unidad', icon: Icons.euro))),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: qty > 1 ? () => setState(() => qty--) : null),
              Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => qty++)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(
            controller: catC,
            textCapitalization: TextCapitalization.sentences,
            decoration: dec('Categoría (ej. Lácteos, Ropa...)', icon: Icons.sell_outlined)),
        if (cats.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(spacing: 6, children: [
              for (final c in cats)
                ActionChip(label: Text(c), onPressed: () => setState(() => catC.text = c)),
            ]),
          ),
        const SizedBox(height: 20),
        Text('Fecha y hora (opcional)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.event),
              label: Text(date == null ? 'Elegir fecha' : DateFormat('d MMM yyyy', 'es_ES').format(date!))),
          OutlinedButton.icon(
              onPressed: pickTime,
              icon: const Icon(Icons.schedule),
              label: Text(time == null ? 'Elegir hora' : time!.format(context))),
          if (date != null || time != null)
            TextButton(
                onPressed: () => setState(() {
                      date = null;
                      time = null;
                    }),
                child: const Text('Quitar')),
        ]),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: status,
          decoration: dec('Estado (Kanban)', icon: Icons.view_kanban_outlined),
          items: [
            for (final e in kStatuses.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) => setState(() => status = v ?? 'todo'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Favorito'),
          secondary: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.pink : null),
          value: fav,
          onChanged: (v) => setState(() => fav = v),
        ),
      ]),
    );
  }
}
