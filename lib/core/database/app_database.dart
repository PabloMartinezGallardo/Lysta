import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mis_listas/core/models/models.dart';

class Repo {
  static final Repo instance = Repo._();
  Repo._();

  late Database db;
  late Directory attachments;

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    attachments = Directory(p.join(dir.path, 'attachments'));
    await attachments.create(recursive: true);

    db = await openDatabase(
      p.join(dir.path, 'mis_listas.db'),
      version: 1,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            emoji TEXT,
            color INTEGER,
            cover TEXT,
            budget REAL,
            position INTEGER DEFAULT 0,
            view_mode TEXT DEFAULT 'list'
          )''');
        await d.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            list_id INTEGER NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            type TEXT DEFAULT 'text',
            value TEXT DEFAULT '',
            price REAL DEFAULT 0,
            qty INTEGER DEFAULT 1,
            category TEXT DEFAULT '',
            done INTEGER DEFAULT 0,
            fav INTEGER DEFAULT 0,
            position INTEGER DEFAULT 0,
            status TEXT DEFAULT 'todo',
            due TEXT,
            num_tag REAL
          )''');
        await d.execute('''
          CREATE TABLE templates(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            emoji TEXT,
            color INTEGER,
            budget REAL,
            items_json TEXT
          )''');
        await d.execute(
            'CREATE TABLE settings(skey TEXT PRIMARY KEY, svalue TEXT)');
      },
    );
  }

  // ---------- Ajustes ----------
  Future<String?> getSetting(String k) async {
    final r = await db.query('settings', where: 'skey=?', whereArgs: [k]);
    return r.isEmpty ? null : r.first['svalue'] as String?;
  }

  Future<void> setSetting(String k, String v) async {
    await db.insert('settings', {'skey': k, 'svalue': v},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------- Listas ----------
  Future<List<Lista>> lists() async =>
      (await db.query('lists', orderBy: 'position, id'))
          .map(Lista.fromMap)
          .toList();

  Future<Lista> listById(int id) async => Lista.fromMap(
      (await db.query('lists', where: 'id=?', whereArgs: [id])).first);

  Future<int> saveList(Lista l) async {
    if (l.id == null) {
      final r = await db
          .rawQuery('SELECT COALESCE(MAX(position),-1)+1 AS n FROM lists');
      l.position = r.first['n'] as int;
      l.id = await db.insert('lists', l.toMap());
    } else {
      await db.update('lists', l.toMap(), where: 'id=?', whereArgs: [l.id]);
    }
    return l.id!;
  }

  Future<void> deleteList(int id) async {
    await db.delete('lists', where: 'id=?', whereArgs: [id]);
  }

  Future<void> reorder(String table, List<int> ids) async {
    final b = db.batch();
    for (var i = 0; i < ids.length; i++) {
      b.update(table, {'position': i}, where: 'id=?', whereArgs: [ids[i]]);
    }
    await b.commit(noResult: true);
  }

  Future<Map<int, ListStats>> totals() async {
    final rows = await db.rawQuery('''
      SELECT list_id, COUNT(*) c, COALESCE(SUM(done),0) d,
             COALESCE(SUM(price*qty),0) t,
             COALESCE(SUM(CASE WHEN done=1 THEN price*qty ELSE 0 END),0) paid
      FROM items GROUP BY list_id''');
    return {
      for (final r in rows)
        r['list_id'] as int: ListStats(r['c'] as int, r['d'] as int,
            (r['t'] as num).toDouble(), (r['paid'] as num).toDouble())
    };
  }

  // ---------- Elementos ----------
  Future<List<Item>> items(int listId) async => (await db.query('items',
          where: 'list_id=?', whereArgs: [listId], orderBy: 'position, id'))
      .map(Item.fromMap)
      .toList();

  Future<void> saveItem(Item it) async {
    if (it.id == null) {
      final r = await db.rawQuery(
          'SELECT COALESCE(MAX(position),-1)+1 AS n FROM items WHERE list_id=?',
          [it.listId]);
      it.position = r.first['n'] as int;
      it.id = await db.insert('items', it.toMap());
    } else {
      await db.update('items', it.toMap(), where: 'id=?', whereArgs: [it.id]);
    }
  }

  Future<void> deleteItem(int id) async {
    await db.delete('items', where: 'id=?', whereArgs: [id]);
  }

  Future<List<String>> categories() async {
    final r = await db.rawQuery(
        "SELECT DISTINCT category c FROM items WHERE category<>'' ORDER BY c");
    return r.map((e) => e['c'] as String).toList();
  }

  // ---------- Plantillas ----------
  Future<List<TemplateDef>> templates() async {
    final rows = await db.query('templates', orderBy: 'id DESC');
    return rows
        .map((r) => TemplateDef(
              id: r['id'] as int,
              name: r['name'] as String,
              emoji: (r['emoji'] as String?) ?? '📝',
              color: (r['color'] as int?) ?? 0xFFE91E63,
              budget: (r['budget'] as num?)?.toDouble(),
              items: (jsonDecode(r['items_json'] as String) as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList(),
            ))
        .toList();
  }

  Future<void> saveAsTemplate(Lista l, List<Item> items, String name) async {
    final data = items
        .map((i) => {
              'title': i.title,
              'type': i.type,
              'category': i.category,
              'price': i.price,
              'qty': i.qty,
              'value': (i.type == 'image' || i.type == 'file' || i.type == 'voice')
                  ? ''
                  : i.value,
              'numTag': i.numTag,
            })
        .toList();
    await db.insert('templates', {
      'name': name,
      'emoji': l.emoji,
      'color': l.color,
      'budget': l.budget,
      'items_json': jsonEncode(data),
    });
  }

  Future<void> deleteTemplate(int id) async {
    await db.delete('templates', where: 'id=?', whereArgs: [id]);
  }

  Future<int> createFromTemplate(TemplateDef t) async {
    final l = Lista(
        name: t.name, emoji: t.emoji, color: t.color, budget: t.budget);
    final id = await saveList(l);
    final b = db.batch();
    for (var i = 0; i < t.items.length; i++) {
      final m = t.items[i];
      b.insert(
          'items',
          Item(
            listId: id,
            title: m['title'] as String,
            type: (m['type'] as String?) ?? 'check',
            category: (m['category'] as String?) ?? '',
            price: (m['price'] as num?)?.toDouble() ?? 0,
            qty: (m['qty'] as num?)?.toInt() ?? 1,
            value: (m['value'] as String?) ?? '',
            numTag: (m['numTag'] as num?)?.toDouble(),
            position: i,
          ).toMap());
    }
    await b.commit(noResult: true);
    return id;
  }

  // ---------- Estadísticas ----------
  Future<Map<String, dynamic>> stats() async {
    final tot = (await db.rawQuery(
            'SELECT COUNT(*) n, COALESCE(SUM(price*qty),0) t, COALESCE(SUM(fav),0) f FROM items'))
        .first;
    final lists =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM lists')) ??
            0;
    final cats = await db.rawQuery(
        "SELECT category c, COUNT(*) n, COALESCE(SUM(price*qty),0) s FROM items WHERE category<>'' GROUP BY category ORDER BY s DESC, n DESC LIMIT 8");
    final top = await db.rawQuery(
        'SELECT MIN(title) t, COUNT(*) n, COALESCE(SUM(price*qty),0) s FROM items GROUP BY LOWER(TRIM(title)) ORDER BY n DESC, s DESC LIMIT 10');
    final favs = await db.rawQuery(
        'SELECT MIN(title) t FROM items WHERE fav=1 GROUP BY LOWER(TRIM(title)) LIMIT 40');
    return {
      'lists': lists,
      'items': tot['n'] as int,
      'spend': (tot['t'] as num).toDouble(),
      'favs': (tot['f'] as num).toInt(),
      'cats': cats,
      'top': top,
      'favList': favs,
    };
  }
}
