import 'package:flutter/material.dart';
import 'package:zayrova/presentation/routes/zay_screens.dart';

final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

class ZayRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = (settings.arguments ?? <String, dynamic>{}) as Map;
    return ZayScreens.route(settings.name, args);
  }

  static Route<dynamic> init(RouteSettings settings) {
    final args = (settings.arguments ?? <String, dynamic>{}) as Map;
    return ZayScreens.route(settings.name, args);
  }
}
