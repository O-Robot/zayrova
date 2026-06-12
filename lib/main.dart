import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/zay.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: true,
        tools: const [...DevicePreview.defaultTools],
        builder: (context) => const ZayApp(),
      ),
    ),
  );
}
