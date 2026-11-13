import 'package:flutter/material.dart';
import 'package:mis_listas/core/utils/format.dart';

class BudgetCard extends StatelessWidget {
  final double total, paid;
  final double? budget;
  const BudgetCard(
      {super.key, required this.total, required this.paid, this.budget});

  @override
  Widget build(BuildContext context) {
    final hasBudget = budget != null && budget! > 0;
    final over = hasBudget && total > budget!;
    final color = over ? Colors.red : Colors.green;
    Widget stat(String l, String v) => Expanded(
          child: Column(children: [
            Text(l, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            Text(v,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
        );
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            stat('Total', money(total)),
            stat('Comprado', money(paid)),
            if (hasBudget) stat('Presupuesto', money(budget!)),
          ]),
          if (hasBudget) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (total / budget!).clamp(0.0, 1.0),
                minHeight: 10,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              over
                  ? '⚠️ Te pasas del presupuesto por ${money(total - budget!)}'
                  : '✅ Te sobran ${money(budget! - total)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ]),
      ),
    );
  }
}
