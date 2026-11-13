import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:table_calendar/table_calendar.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/models/models.dart';
import 'package:mis_listas/core/utils/utils.dart';
import 'package:mis_listas/core/widgets/widgets.dart';
import 'package:mis_listas/features/items/item_form_screen.dart';
import 'package:mis_listas/features/lists/list_form_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final Lista list;
  const ListDetailScreen({super.key, required this.list});
  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  late Lista list = widget.list;
  List<Item> items = [];
  late String view = list.viewMode;
  DateTime focused = DateTime.now();
  DateTime selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final r = await Repo.instance.items(list.id!);
    if (mounted) setState(() => items = r);
  }

  double get total => items.fold(0.0, (a, i) => a + i.total);
  double get paid => items.where((i) => i.done).fold(0.0, (a, i) => a + i.total);

  Future<void> addItem() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => ItemFormScreen(listId: list.id!)));
    load();
  }

  Future<void> editItem(Item it) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ItemFormScreen(listId: list.id!, item: it)));
    load();
  }

  Future<void> toggleDone(Item it) async {
    it.done = !it.done;
    it.status = it.done ? 'done' : 'todo';
    setState(() {});
    await Repo.instance.saveItem(it);
  }

  Future<void> toggleFav(Item it) async {
    it.fav = !it.fav;
    setState(() {});
    await Repo.instance.saveItem(it);
  }

  Future<void> moveTo(Item it, String status) async {
    it.status = status;
    it.done = status == 'done';
    setState(() {});
    await Repo.instance.saveItem(it);
  }

  Future<void> setView(String v) async {
    setState(() => view = v);
    list.viewMode = v;
    await Repo.instance.saveList(list);
  }

  Future<void> onMenu(String v) async {
    if (v == 'edit') {
      final l = await Navigator.push<Lista>(context,
          MaterialPageRoute(builder: (_) => ListFormScreen(list: list)));
      if (l != null) setState(() => list = l);
    } else if (v == 'template') {
      final c = TextEditingController(text: list.name);
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Guardar como plantilla'),
          content: TextField(controller: c, decoration: dec('Nombre de la plantilla')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Guardar')),
          ],
        ),
      );
      if (name != null && name.isNotEmpty) {
        await Repo.instance.saveAsTemplate(list, items, name);
        if (mounted) snack(context, 'Plantilla guardada ✨');
      }
    } else if (v == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Borrar la lista?'),
          content: Text('Se borrará «${list.name}» con todos sus elementos.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
          ],
        ),
      );
      if (ok == true) {
        await Repo.instance.deleteList(list.id!);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  String meta(Item it) {
    final parts = <String>[];
    if (it.category.isNotEmpty) parts.add(it.category);
    switch (it.type) {
      case 'text':
      case 'link':
        if (it.value.isNotEmpty) parts.add(it.value);
        break;
      case 'file':
        if (it.value.isNotEmpty) parts.add('📎 ${p.basename(it.value)}');
        break;
      case 'voice':
        parts.add('🎙️ Nota de voz');
        break;
      case 'number':
        parts.add('${it.value.isEmpty ? '#' : it.value}: ${it.numTag == null ? '-' : shortNum(it.numTag!)}');
        break;
    }
    if (it.price > 0) parts.add('${it.qty} × ${money(it.price)}');
    if (it.due != null) parts.add('📅 ${fmtDue(it)}');
    return parts.join(' · ');
  }

  Widget thumb(Item it, {double h = 70}) {
    if (it.type == 'image' && it.value.isNotEmpty && File(it.value).existsSync()) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(it.value), height: h, fit: BoxFit.cover),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${list.emoji}  ${list.name}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar lista')),
              PopupMenuItem(value: 'template', child: Text('Guardar como plantilla')),
              PopupMenuItem(value: 'delete', child: Text('Borrar lista')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addItem,
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: Column(children: [
        BudgetCard(total: total, paid: paid, budget: list.budget),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'list', icon: Icon(Icons.view_list), label: Text('Lista')),
              ButtonSegment(value: 'kanban', icon: Icon(Icons.view_kanban_outlined), label: Text('Kanban')),
              ButtonSegment(value: 'calendar', icon: Icon(Icons.calendar_month), label: Text('Calendario')),
            ],
            selected: {view},
            onSelectionChanged: (s) => setView(s.first),
          ),
        ),
        Expanded(
          child: view == 'kanban'
              ? kanban()
              : view == 'calendar'
                  ? calendar()
                  : listView(),
        ),
      ]),
    );
  }

  // ---------- Vista lista ----------
  Widget listView() {
    if (items.isEmpty) {
      return const Center(child: Text('Pulsa «Añadir» para meter tu primer elemento ✨'));
    }
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
      itemCount: items.length,
      onReorder: (o, n) {
        if (n > o) n--;
        final x = items.removeAt(o);
        items.insert(n, x);
        setState(() {});
        Repo.instance.reorder('items', items.map((e) => e.id!).toList());
      },
      itemBuilder: (c, i) => tile(items[i], i),
    );
  }

  Widget tile(Item it, int index, {bool reorderable = true}) {
    return Card(
      key: ValueKey('item_${it.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => editItem(it),
        leading: Checkbox(value: it.done, onChanged: (_) => toggleDone(it)),
        title: Text(it.title,
            style: TextStyle(
                decoration: it.done ? TextDecoration.lineThrough : null,
                color: it.done ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (meta(it).isNotEmpty) Text(meta(it), maxLines: 2, overflow: TextOverflow.ellipsis),
          thumb(it),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (it.type == 'voice' && it.value.isNotEmpty) PlayButton(it.value),
          if (it.type == 'link' && it.value.isNotEmpty)
            IconButton(icon: const Icon(Icons.open_in_new), onPressed: () => openLink(context, it.value)),
          if (it.type == 'file' && it.value.isNotEmpty)
            IconButton(icon: const Icon(Icons.open_in_new), onPressed: () => openAttachment(context, it.value)),
          if (it.price > 0)
            Text(money(it.total), style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            icon: Icon(it.fav ? Icons.favorite : Icons.favorite_border,
                color: it.fav ? Colors.pink : null),
            onPressed: () => toggleFav(it),
          ),
          if (reorderable)
            ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
        ]),
      ),
    );
  }

  // ---------- Vista Kanban ----------
  Widget kanban() {
    return LayoutBuilder(builder: (ctx, cs) {
      final w = cs.maxWidth > 900 ? (cs.maxWidth - 48) / 3 : 280.0;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final e in kStatuses.entries)
            SizedBox(width: w, height: cs.maxHeight - 24, child: column(e.key, e.value)),
        ]),
      );
    });
  }

  Widget column(String status, String title) {
    final col = items.where((i) => i.status == status).toList();
    return DragTarget<Item>(
      onWillAcceptWithDetails: (d) => d.data.status != status,
      onAcceptWithDetails: (d) => moveTo(d.data, status),
      builder: (ctx, cand, rej) => Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cand.isNotEmpty
              ? Theme.of(context).colorScheme.primary.withAlpha(40)
              : Colors.grey.withAlpha(35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              CircleAvatar(radius: 11, child: Text('${col.length}', style: const TextStyle(fontSize: 12))),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              children: [for (final it in col) kanbanCard(it)],
            ),
          ),
        ]),
      ),
    );
  }

  Widget kanbanCard(Item it) {
    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => editItem(it),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(typeOf(it.type).icon, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              if (it.fav) const Icon(Icons.favorite, size: 16, color: Colors.pink),
            ]),
            if (meta(it).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(meta(it), maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            thumb(it, h: 60),
            if (it.price > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(money(it.total), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ]),
        ),
      ),
    );
    return LongPressDraggable<Item>(
      data: it,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 250, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  // ---------- Vista calendario ----------
  List<Item> eventsFor(DateTime day) =>
      items.where((i) => i.dueDate != null && isSameDay(i.dueDate, day)).toList();

  Widget calendar() {
    final day = eventsFor(selected);
    return ListView(padding: const EdgeInsets.only(bottom: 96), children: [
      TableCalendar<Item>(
        locale: 'es_ES',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: focused,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
        selectedDayPredicate: (d) => isSameDay(d, selected),
        eventLoader: eventsFor,
        onDaySelected: (s, f) => setState(() {
          selected = s;
          focused = f;
        }),
        onPageChanged: (f) => focused = f,
      ),
      const Divider(),
      if (items.every((i) => i.due == null))
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Ponle fecha a los elementos para verlos aquí 📅', textAlign: TextAlign.center),
        )
      else if (day.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Nada programado este día', textAlign: TextAlign.center),
        )
      else
        for (var i = 0; i < day.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: tile(day[i], i, reorderable: false),
          ),
    ]);
  }
}
