import 'package:flutter/material.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/models/models.dart';
import 'package:mis_listas/features/templates/builtin_templates.dart';
import 'package:mis_listas/features/lists/list_detail_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});
  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<TemplateDef> mine = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final t = await Repo.instance.templates();
    if (mounted) setState(() => mine = t);
  }

  Future<void> use(TemplateDef t) async {
    final id = await Repo.instance.createFromTemplate(t);
    final l = await Repo.instance.listById(id);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => ListDetailScreen(list: l)));
  }

  Widget card(TemplateDef t, {bool deletable = false}) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(t.color).withAlpha(50),
            child: Text(t.emoji, style: const TextStyle(fontSize: 22)),
          ),
          title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${t.items.length} elementos'),
          trailing: deletable
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await Repo.instance.deleteTemplate(t.id!);
                    load();
                  })
              : const Icon(Icons.chevron_right),
          onTap: () => use(t),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plantillas'),
          bottom: const TabBar(tabs: [Tab(text: 'Predefinidas'), Tab(text: 'Mis plantillas')]),
        ),
        body: TabBarView(children: [
          ListView(padding: const EdgeInsets.all(12), children: [
            for (final t in builtInTemplates) card(t),
          ]),
          mine.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Aún no tienes plantillas propias.\nAbre una lista → menú ⋮ → «Guardar como plantilla».',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(padding: const EdgeInsets.all(12), children: [
                  for (final t in mine) card(t, deletable: true),
                ]),
        ]),
      ),
    );
  }
}
