import 'package:flutter/material.dart';
import 'package:zayrova/presentation/pages/onboarding/get_started_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/splash_screen.dart';
import 'package:zayrova/presentation/pages/error/error_screen.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class ZayScreens {
  static MaterialPageRoute route(String? route, data) {
    switch (route) {
      case ZayRoutes.splash:
        return MaterialPageRoute(builder: (context) => const Splashscreen());
      case ZayRoutes.getStarted:
        return MaterialPageRoute(
          builder: (context) => const GetStartedScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(code: 404),
        );
    }
  }
}
