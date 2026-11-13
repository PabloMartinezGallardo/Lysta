import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mis_listas/core/database/app_database.dart';
import 'package:mis_listas/core/utils/utils.dart';
import 'package:mis_listas/core/widgets/widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Repo.instance.stats(),
        builder: (c, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final s = snap.data!;
          if ((s['items'] as int) == 0) {
            return const Center(child: Text('Añade elementos a tus listas para ver estadísticas 📊'));
          }
          final cats = s['cats'] as List<Map<String, Object?>>;
          final top = s['top'] as List<Map<String, Object?>>;
          final favs = s['favList'] as List<Map<String, Object?>>;
          final useSpend = cats.any((e) => (e['s'] as num) > 0);
          double val(Map<String, Object?> e) =>
              useSpend ? (e['s'] as num).toDouble() : (e['n'] as num).toDouble();
          final totalVal = cats.fold(0.0, (a, e) => a + val(e));
          final colors = [
            Colors.pink, Colors.purple, Colors.blue, Colors.teal,
            Colors.orange, Colors.green, Colors.brown, Colors.indigo,
          ];

          Widget box(String label, String value) => Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(children: [
                      Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ),
              );

          return ListView(padding: const EdgeInsets.all(12), children: [
            Row(children: [
              box('Listas', '${s['lists']}'),
              box('Elementos', '${s['items']}'),
              box('Gasto total', money(s['spend'] as double)),
              box('Favoritos', '${s['favs']}'),
            ]),
            if (cats.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(useSpend ? 'Gasto por categoría' : 'Elementos por categoría',
                  style: Theme.of(context).textTheme.titleMedium),
              SizedBox(
                height: 220,
                child: PieChart(PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                  sections: [
                    for (var i = 0; i < cats.length; i++)
                      PieChartSectionData(
                        value: val(cats[i]) <= 0 ? 0.001 : val(cats[i]),
                        color: colors[i % colors.length],
                        radius: 62,
                        title: totalVal > 0 ? '${(val(cats[i]) / totalVal * 100).round()}%' : '',
                        titleStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                  ],
                )),
              ),
              for (var i = 0; i < cats.length; i++)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 8, backgroundColor: colors[i % colors.length]),
                  title: Text(cats[i]['c'] as String),
                  trailing: Text(useSpend
                      ? money(cats[i]['s'] as num)
                      : '${cats[i]['n']} elem.'),
                ),
            ],
            const SizedBox(height: 12),
            Text('Lo que más repites', style: Theme.of(context).textTheme.titleMedium),
            for (final e in top)
              ListTile(
                dense: true,
                leading: const Icon(Icons.repeat),
                title: Text(e['t'] as String),
                subtitle: Text('${e['n']} ${(e['n'] as int) == 1 ? 'vez' : 'veces'}'),
                trailing: (e['s'] as num) > 0 ? Text(money(e['s'] as num)) : null,
              ),
            if (favs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Tus favoritos ❤️', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final f in favs) Chip(label: Text(f['t'] as String)),
              ]),
            ],
            const SizedBox(height: 40),
          ]);
        },
      ),
    );
  }
}
