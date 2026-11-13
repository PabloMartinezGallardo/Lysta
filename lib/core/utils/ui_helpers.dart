import 'package:flutter/material.dart';

const kPalette = <int>[
  0xFFE91E63, 0xFFF44336, 0xFFFF5722, 0xFFFF9800,
  0xFFFFC107, 0xFF8BC34A, 0xFF4CAF50, 0xFF009688,
  0xFF00BCD4, 0xFF2196F3, 0xFF3F51B5, 0xFF673AB7,
  0xFF9C27B0, 0xFF795548, 0xFF607D8B, 0xFFEC407A,
];

const kEmojis = <String>[
  '🛒', '🧳', '🎯', '💪', '📦', '🎁', '🍎', '🥦', '🍕', '☕',
  '👗', '👠', '💄', '🧴', '🏠', '🛋️', '🌿', '🐶', '🐱', '✈️',
  '🏖️', '🎬', '📚', '🎵', '🎮', '💻', '📱', '🧶', '🎨', '🍰',
  '🎂', '💍', '❤️', '⭐', '🌸', '🧘', '🚴', '💊', '🧾', '📝',
];

InputDecoration dec(String label, {String? hint, IconData? icon}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );

void snack(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

