import 'package:flutter/material.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class BottomButton extends StatelessWidget {
  final VoidCallback onProceed;
  final String text;

  const BottomButton({super.key, required this.onProceed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: ZayButton.primary(action: onProceed, text: text),
    );
  }
}
