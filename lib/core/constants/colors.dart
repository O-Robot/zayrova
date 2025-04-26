import 'package:flutter/material.dart';

class ZayColors {
  static const Color primary = Color(0xFF2D6A4F);
  static const Color secondary = Color(0xFFFFB703);
  static const Color accent = Color(0xFF64B5F6);
  static const Color background = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const LinearGradient gradient = LinearGradient(
    colors: [primary, Color(0xFFA09036), secondary],
    stops: [0.0, 0.76, 1.0],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
