import 'package:flutter/material.dart';
import 'package:zayrova/presentation/routes/zay_screens.dart';

final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

class ZayRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = (settings.arguments ?? <String, dynamic>{}) as Map;
    return ZayScreens.route(settings.name, args);
  }

  static goto(String route, [Map? parameters]) {
    var args = parameters ?? {};
    return navigator.currentState?.pushNamed(
      // global states routing
      route,
      arguments: args,
    );
  }

  static exit(String route, [Map? parameters]) {
    var args = parameters ?? {};
    return navigator.currentState?.popAndPushNamed(route, arguments: args);
  }

  static goBack([int history = 1]) {
    for (int i = 0; i < history; i++) {
      navigator.currentState?.pop(true);
    }
  }

  static void refresh() {
    // Access the current route's settings
    final currentSettings =
        ModalRoute.of(navigator.currentState!.context)?.settings;

    if (currentSettings != null) {
      final currentRouteName = currentSettings.name;
      final args = currentSettings.arguments as Map<String, dynamic>? ?? {};

      // Re-push the current route to refresh the page
      navigator.currentState?.pushReplacementNamed(
        currentRouteName!,
        arguments: args,
      );
    }
  }
}
