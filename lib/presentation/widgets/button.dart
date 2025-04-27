import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';

class ZayButton {
  static Widget primary({required VoidCallback action, required String text}) {
    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: ZayColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
