import 'package:flutter/material.dart';
import 'package:zayrova/zay.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const ZayApp(),
    ),
  );
}
