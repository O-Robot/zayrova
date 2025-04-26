import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: false,
      // appBar: null,
      body: Container(
        color: ZayColors.primary, // Set the background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(ZayAssets.logoSplash, width: 100, height: 100),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
