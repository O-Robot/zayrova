import 'package:flutter/material.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class ZayApp extends StatelessWidget {
  const ZayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zayrova',
      theme: ZayTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      initialRoute: ZayRoutes.splash,
      navigatorKey: navigator,
      onGenerateRoute: ZayRouter.generateRoute,
    );
  }
}
