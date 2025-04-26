import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';

class ZayTheme {
  static final ThemeData lightTheme = ThemeData(
      primaryColor: ZayColors.primary,
      scaffoldBackgroundColor: ZayColors.background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ZayColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ZayColors.textPrimary,
        ),
        displayLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ZayColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ZayColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 24.5,
          fontWeight: FontWeight.w700,
          color: ZayColors.textPrimary,
        ),
      ));
}
