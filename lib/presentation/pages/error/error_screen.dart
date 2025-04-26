import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.code,
  });

  final int code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Error: $code',
          style: const TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}
