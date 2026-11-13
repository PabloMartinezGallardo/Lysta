import 'package:mis_listas/core/models/models.dart';

Map<String, dynamic> _i(String title, String cat,
        {double price = 0, int qty = 1, String type = 'check', String value = '', double? tag}) =>
    {'title': title, 'category': cat, 'price': price, 'qty': qty, 'type': type, 'value': value, 'numTag': tag};

final List<TemplateDef> builtInTemplates = [
  TemplateDef(
    name: 'Supermercado',
    emoji: '🛒',
    color: 0xFF4CAF50,
    budget: 60,
    items: [
      _i('Manzanas', 'Fruta y verdura', price: 2.5),
      _i('Plátanos', 'Fruta y verdura', price: 1.8),
      _i('Tomates', 'Fruta y verdura', price: 2.2),
      _i('Leche', 'Lácteos', price: 0.95, qty: 6),
      _i('Yogures', 'Lácteos', price: 2.0),
      _i('Pan', 'Panadería', price: 1.2),
      _i('Pollo', 'Carne y pescado', price: 6.5),
      _i('Pasta', 'Despensa', price: 1.1, qty: 2),
      _i('Arroz', 'Despensa', price: 1.6),
      _i('Detergente', 'Limpieza', price: 5.9),
    ],
  ),
  TemplateDef(
    name: 'Maleta de viaje',
    emoji: '🧳',
    color: 0xFF2196F3,
    items: [
      _i('DNI / Pasaporte', 'Documentos'),
      _i('Billetes y reservas', 'Documentos'),
      _i('Móvil y cargador', 'Tecnología'),
      _i('Auriculares', 'Tecnología'),
      _i('Ropa interior', 'Ropa', qty: 5),
      _i('Camisetas', 'Ropa', qty: 4),
      _i('Pijama', 'Ropa'),
      _i('Calzado cómodo', 'Ropa'),
      _i('Neceser', 'Aseo'),
      _i('Protector solar', 'Aseo'),
    ],
  ),
  TemplateDef(
    name: 'Objetivos del año',
    emoji: '🎯',
    color: 0xFF9C27B0,
    items: [
      _i('Hacer ejercicio 3 veces por semana', 'Salud'),
      _i('Dormir 8 horas', 'Salud'),
      _i('Ahorrar para un viaje', 'Dinero', price: 1000),
      _i('Leer 12 libros', 'Personal', type: 'number', value: 'Libros', tag: 12),
      _i('Aprender algo nuevo', 'Personal'),
      _i('Hacer una escapada especial', 'Viajes'),
    ],
  ),
  TemplateDef(
    name: 'Rutina de ejercicios',
    emoji: '💪',
    color: 0xFFFF5722,
    items: [
      _i('Calentamiento 10 min', 'Lunes'),
      _i('Sentadillas', 'Lunes', type: 'number', value: 'Series', tag: 4),
      _i('Zancadas', 'Lunes', type: 'number', value: 'Series', tag: 3),
      _i('Flexiones', 'Miércoles', type: 'number', value: 'Series', tag: 4),
      _i('Plancha', 'Miércoles', type: 'number', value: 'Series', tag: 3),
      _i('Cardio 30 min', 'Viernes'),
      _i('Estiramientos', 'Viernes'),
    ],
  ),
  TemplateDef(
    name: 'Inventario',
    emoji: '📦',
    color: 0xFF795548,
    items: [
      _i('Producto 1', 'General', price: 10, qty: 1, type: 'text'),
      _i('Producto 2', 'General', price: 5, qty: 3, type: 'text'),
      _i('Producto 3', 'General', price: 20, qty: 2, type: 'text'),
    ],
  ),
];
