import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/primary_button.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:flutter/gestures.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(ZayAssets.background, fit: BoxFit.cover),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ZayIllustrations.getStarted,
                  width: 279,
                  height: 419,
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "The ",
                        style: ZayTheme.lightTheme.textTheme.titleLarge,
                      ),
                      TextSpan(
                        text: "Smartest Way ",
                        style: ZayTheme.lightTheme.textTheme.titleLarge
                            ?.copyWith(color: ZayColors.primary),
                      ),
                      TextSpan(
                        text: "to",
                        style: ZayTheme.lightTheme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Shop, All in One App',
                  style: ZayTheme.lightTheme.textTheme.titleLarge,
                ),

                const SizedBox(height: 2),
                Text(
                  'Discover, compare, and shop\n'
                  'everything you need—simplified.',
                  textAlign: TextAlign.center,
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  action: () {
                    ZayRouter.exit(ZayRoutes.onboardingPage);
                  },
                  text: 'Get Started',
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already have an account? ",
                        style: ZayTheme.lightTheme.textTheme.displayLarge,
                      ),
                      TextSpan(
                        text: "Sign In",
                        style: ZayTheme.lightTheme.textTheme.displayLarge
                            ?.copyWith(
                              color: ZayColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                ZayRouter.exit(ZayRoutes.login);
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
