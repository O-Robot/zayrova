import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/navigation_dots.dart';
import 'package:zayrova/presentation/pages/onboarding/onboarding_page.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    OnboardingPage(
      title: 'Endless Products, \n One App',
      description:
          'Browse a world of items, from essentials\n'
          'to unique finds—all at your fingertips.',
      image: ZayIllustrations.onboardingOne,
    ),
    OnboardingPage(
      title: 'Personalized\n Just for You!',
      description:
          'Get smarter recommendations\n based on what you like and how you shop.',
      image: ZayIllustrations.onboardingTwo,
    ),
    OnboardingPage(
      title: 'Secure & Smooth\n Checkout',
      description:
          'Fast payments, safe delivery, and\n full peace of mind with every order.',
      image: ZayIllustrations.onboardingThree,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(ZayAssets.background, fit: BoxFit.cover),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => _pages[index],
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ZayColors.primary),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: ZayColors.primary,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      ZayRouter.exit(ZayRoutes.login);
                    },
                    child: Text(
                      'Skip',
                      style: ZayTheme.lightTheme.textTheme.displayMedium,
                    ),
                  ),
                Row(
                  children: [
                    NavigationDots(
                      length: _pages.length,
                      currentPage: _currentPage,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      ZayRouter.exit(ZayRoutes.login);
                    }
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
    );
  }
}
