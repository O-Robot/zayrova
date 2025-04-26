import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/utils/local_storage.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:animate_do/animate_do.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    LocalStorage.delete('onboard');

    await LocalStorage.get('guest', bool).then((guest) async {
      if (guest == true) {
        await LocalStorage.set('onboard', false);
        ZayRouter.exit(ZayRoutes.login);
        return;
      }
    });

    await Future.delayed(const Duration(seconds: 2));
    // ZayRouter.exit(ZayRoutes.getStarted);
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
              child: FadeIn(
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
