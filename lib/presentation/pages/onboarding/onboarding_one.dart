import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/navigation_dots.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class OnboardingOne extends StatelessWidget {
  const OnboardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(ZayAssets.background, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          ZayIllustrations.onboardingOne,
                          width: 280,
                          height: 280,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Endless Products,',
                          textAlign: TextAlign.center,
                          style: ZayTheme.lightTheme.textTheme.titleLarge,
                        ),
                        Text(
                          'One App',
                          textAlign: TextAlign.center,
                          style: ZayTheme.lightTheme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Browse a world of items, from essentials\n'
                          'to unique finds—all at your fingertips.',
                          textAlign: TextAlign.center,
                          style: ZayTheme.lightTheme.textTheme.displayMedium
                              ?.copyWith(color: ZayColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(padding: const EdgeInsets.all(12)),
                      ),
                      // Navigation dots
                      Row(
                        children: [
                          NavigationDots(
                            routes: [
                              ZayRoutes.onboard1,
                              ZayRoutes.onboard2,
                              ZayRoutes.onboard3,
                            ],
                            activeIndex: 0,
                          ),
                        ],
                      ),
                      // Right arrow button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/onboarding_two');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZayColors.primary,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: ZayColors.white,
                          ),
                        ),
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
