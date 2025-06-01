import 'package:flutter/material.dart';
import 'package:zayrova/presentation/pages/auth/complete_profile.dart';
import 'package:zayrova/presentation/pages/auth/sign_up.dart';
import 'package:zayrova/presentation/pages/auth/forgot_password.dart';
import 'package:zayrova/presentation/pages/auth/set_password.dart';
import 'package:zayrova/presentation/pages/auth/verify_email.dart';
import 'package:zayrova/presentation/pages/home/home_screen.dart';
import 'package:zayrova/presentation/pages/location/location_access.dart';
import 'package:zayrova/presentation/pages/location/location_page.dart';
import 'package:zayrova/presentation/pages/onboarding/get_started_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/splash_screen.dart';
import 'package:zayrova/presentation/pages/error/error_screen.dart';
import 'package:zayrova/presentation/pages/auth/sign_in.dart';
import 'package:zayrova/presentation/pages/product/product_details.dart';
import 'package:zayrova/presentation/pages/product/wishlist_screen.dart';
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
      case ZayRoutes.onboardingPage:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case ZayRoutes.login:
        return MaterialPageRoute(builder: (context) => const SignIn());
      case ZayRoutes.register:
        return MaterialPageRoute(builder: (context) => const SignUp());
      case ZayRoutes.forgotPassword:
        return MaterialPageRoute(builder: (context) => const ForgotPassword());
      case ZayRoutes.verifyEmail:
        return MaterialPageRoute(builder: (context) => const VerifyEmail());
      case ZayRoutes.setPassword:
        return MaterialPageRoute(builder: (context) => const SetPassword());
      case ZayRoutes.completeProfile:
        return MaterialPageRoute(builder: (context) => const CompleteProfile());
      case ZayRoutes.locationAccess:
        return MaterialPageRoute(builder: (context) => const LocationAccess());
      case ZayRoutes.locationPage:
        return MaterialPageRoute(builder: (context) => const LocationPage());
      case ZayRoutes.home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case ZayRoutes.productDetails:
        return MaterialPageRoute(builder: (context) => const ProductDetails());
      case ZayRoutes.wishlist:
        return MaterialPageRoute(builder: (context) => const WishlistScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(code: 404),
        );
    }
  }
}
