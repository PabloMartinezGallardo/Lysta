import 'package:flutter/material.dart';

class ItemType {
  final String id, label;
  final IconData icon;
  const ItemType(this.id, this.label, this.icon);
}

const kTypes = <ItemType>[
  ItemType('text', 'Texto', Icons.notes),
  ItemType('check', 'Casilla', Icons.check_box_outlined),
  ItemType('image', 'Imagen', Icons.image_outlined),
  ItemType('link', 'Enlace', Icons.link),
  ItemType('date', 'Fecha', Icons.event),
  ItemType('time', 'Hora', Icons.schedule),
  ItemType('voice', 'Nota de voz', Icons.mic_none),
  ItemType('file', 'Archivo', Icons.attach_file),
  ItemType('number', 'Etiqueta numérica', Icons.pin_outlined),
];

ItemType typeOf(String id) =>
    kTypes.firstWhere((t) => t.id == id, orElse: () => kTypes.first);

const kStatuses = {'todo': 'Por hacer', 'doing': 'En curso', 'done': 'Hecho'};

class Lista {
  int? id;
  String name;
  String emoji;
  int color;
  String? cover;
  double? budget;
  int position;
  String viewMode;

  Lista({
    this.id,
    required this.name,
    this.emoji = '📝',
    this.color = 0xFFE91E63,
    this.cover,
    this.budget,
    this.position = 0,
    this.viewMode = 'list',
  });

  factory Lista.fromMap(Map<String, Object?> m) => Lista(
        id: m['id'] as int,
        name: m['name'] as String,
        emoji: (m['emoji'] as String?) ?? '📝',
        color: (m['color'] as int?) ?? 0xFFE91E63,
        cover: m['cover'] as String?,
        budget: (m['budget'] as num?)?.toDouble(),
        position: (m['position'] as int?) ?? 0,
        viewMode: (m['view_mode'] as String?) ?? 'list',
      );

  Map<String, Object?> toMap() => {
        'name': name,
        'emoji': emoji,
        'color': color,
        'cover': cover,
        'budget': budget,
        'position': position,
        'view_mode': viewMode,
      };
}

class Item {
  int? id;
  int listId;
  String title;
  String type;
  String value; // texto, url, ruta de imagen/archivo/audio o etiqueta
  double price;
  int qty;
  String category;
  bool done;
  bool fav;
  int position;
  String status;
  String? due; // yyyy-MM-dd  o  yyyy-MM-ddTHH:mm
  double? numTag;

  Item({
    this.id,
    required this.listId,
    required this.title,
    this.type = 'text',
    this.value = '',
    this.price = 0,
    this.qty = 1,
    this.category = '',
    this.done = false,
    this.fav = false,
    this.position = 0,
    this.status = 'todo',
    this.due,
    this.numTag,
  });

  double get total => price * qty;
  DateTime? get dueDate => due == null ? null : DateTime.tryParse(due!);
  bool get hasTime => due != null && due!.contains('T');

  factory Item.fromMap(Map<String, Object?> m) => Item(
        id: m['id'] as int,
        listId: m['list_id'] as int,
        title: (m['title'] as String?) ?? '',
        type: (m['type'] as String?) ?? 'text',
        value: (m['value'] as String?) ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        qty: (m['qty'] as int?) ?? 1,
        category: (m['category'] as String?) ?? '',
        done: (m['done'] as int?) == 1,
        fav: (m['fav'] as int?) == 1,
        position: (m['position'] as int?) ?? 0,
        status: (m['status'] as String?) ?? 'todo',
        due: m['due'] as String?,
        numTag: (m['num_tag'] as num?)?.toDouble(),
      );

  Map<String, Object?> toMap() => {
        'list_id': listId,
        'title': title,
        'type': type,
        'value': value,
        'price': price,
        'qty': qty,
        'category': category,
        'done': done ? 1 : 0,
        'fav': fav ? 1 : 0,
        'position': position,
        'status': status,
        'due': due,
        'num_tag': numTag,
      };
}

class ListStats {
  final int count, done;
  final double total, paid;
  const ListStats(this.count, this.done, this.total, this.paid);
}

class TemplateDef {
  int? id;
  String name, emoji;
  int color;
  double? budget;
  List<Map<String, dynamic>> items;
  TemplateDef({
    this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.budget,
    required this.items,
  });
}
