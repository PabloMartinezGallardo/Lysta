import 'package:intl/intl.dart';
import 'package:mis_listas/core/models/models.dart';

final _fmt = NumberFormat.currency(locale: 'es_ES', symbol: '€');
String money(num v) => _fmt.format(v);
String shortNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

String fmtDue(Item it) {
  final d = it.dueDate;
  if (d == null) return '';
  final day = DateFormat('d MMM yyyy', 'es_ES').format(d);
  return it.hasTime ? '$day, ${DateFormat('HH:mm').format(d)}' : day;
}

