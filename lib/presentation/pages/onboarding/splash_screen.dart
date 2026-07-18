import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/utils/local_storage.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:animate_do/animate_do.dart';

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 5));
    await ref.read(authControllerProvider.notifier).restoreSession();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      ZayRouter.exit(ZayRoutes.home);
      return;
    }

    final guest = await LocalStorage.get('guest', bool);
    if (!mounted) {
      return;
    }

    if (guest == true) {
      ZayRouter.exit(ZayRoutes.login);
      return;
    }

    final hasCompletedOnboarding = await LocalStorage.get('onboard', bool);
    if (!mounted) {
      return;
    }

    ZayRouter.exit(
      hasCompletedOnboarding == true ? ZayRoutes.login : ZayRoutes.getStarted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: false,
      // appBar: null,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(ZayAssets.splashBackground, fit: BoxFit.cover),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: FadeInUp(
                delay: const Duration(milliseconds: 1100),
                child: SvgPicture.asset(
                  ZayAssets.logoSplash,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
