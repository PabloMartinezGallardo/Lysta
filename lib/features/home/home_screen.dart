import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/models/models.dart';
import 'package:mis_listas/core/theme/app_theme.dart';
import 'package:mis_listas/core/utils/utils.dart';
import 'package:mis_listas/core/widgets/widgets.dart';
import 'package:mis_listas/features/lists/list_detail_screen.dart';
import 'package:mis_listas/features/lists/list_form_screen.dart';
import 'package:mis_listas/features/stats/stats_screen.dart';
import 'package:mis_listas/features/templates/templates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Lista> lists = [];
  Map<int, ListStats> stats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final l = await Repo.instance.lists();
    final s = await Repo.instance.totals();
    if (!mounted) return;
    setState(() {
      lists = l;
      stats = s;
      loading = false;
    });
  }

  Future<void> open(Lista l) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ListDetailScreen(list: l)));
    load();
  }

  Future<void> newList() async {
    final l = await Navigator.push<Lista>(
        context, MaterialPageRoute(builder: (_) => const ListFormScreen()));
    if (l != null && mounted) await open(l);
    load();
  }

  Future<void> templates() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const TemplatesScreen()));
    load();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis listas'),
        actions: [
          IconButton(
            tooltip: 'Estadísticas',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            tooltip: 'Plantillas',
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: templates,
          ),
          IconButton(
            tooltip: dark ? 'Modo claro' : 'Modo oscuro',
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ThemeController.instance.setDark(!dark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: newList,
        icon: const Icon(Icons.add),
        label: const Text('Nueva lista'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : lists.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🗒️', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      Text('Aún no tienes listas',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text(
                          'Crea una desde cero o empieza con una plantilla.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: templates,
                        icon: const Icon(Icons.dashboard_customize_outlined),
                        label: const Text('Ver plantillas'),
                      ),
                    ]),
                  ),
                )
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  itemCount: lists.length,
                  onReorder: (o, n) {
                    if (n > o) n--;
                    final x = lists.removeAt(o);
                    lists.insert(n, x);
                    setState(() {});
                    Repo.instance
                        .reorder('lists', lists.map((e) => e.id!).toList());
                  },
                  itemBuilder: (c, i) => _card(lists[i], i),
                ),
    );
  }

  Widget _card(Lista l, int i) {
    final s = stats[l.id!];
    final color = Color(l.color);
    final hasCover = l.cover != null && File(l.cover!).existsSync();
    final over = l.budget != null && s != null && s.total > l.budget!;
    return Card(
      key: ValueKey(l.id),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => open(l),
        child: Column(children: [
          if (hasCover)
            SizedBox(
                height: 90,
                width: double.infinity,
                child: Image.file(File(l.cover!), fit: BoxFit.cover)),
          Container(
            decoration: BoxDecoration(
                border: Border(left: BorderSide(color: color, width: 6))),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withAlpha(50),
                child: Text(l.emoji, style: const TextStyle(fontSize: 22)),
              ),
              title: Text(l.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                s == null
                    ? 'Vacía'
                    : '${s.done}/${s.count} hechos · ${money(s.total)}'
                        '${l.budget != null ? ' de ${money(l.budget!)}' : ''}',
                style: TextStyle(color: over ? Colors.red : null),
              ),
              trailing: ReorderableDragStartListener(
                index: i,
                child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
