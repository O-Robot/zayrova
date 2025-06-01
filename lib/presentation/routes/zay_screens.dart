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
  // 🔧 Helper to wrap pages with route name
  static MaterialPageRoute _page(String name, Widget child) {
    return MaterialPageRoute(
      settings: RouteSettings(name: name),
      builder: (_) => child,
    );
  }

  static MaterialPageRoute route(String? route, data) {
    switch (route) {
      case ZayRoutes.splash:
        return _page(ZayRoutes.splash, const Splashscreen());
      case ZayRoutes.getStarted:
        return _page(ZayRoutes.getStarted, const GetStartedScreen());
      case ZayRoutes.onboardingPage:
        return _page(ZayRoutes.onboardingPage, const OnboardingScreen());
      case ZayRoutes.login:
        return _page(ZayRoutes.login, const SignIn());
      case ZayRoutes.register:
        return _page(ZayRoutes.register, const SignUp());
      case ZayRoutes.forgotPassword:
        return _page(ZayRoutes.forgotPassword, const ForgotPassword());
      case ZayRoutes.verifyEmail:
        return _page(ZayRoutes.verifyEmail, const VerifyEmail());
      case ZayRoutes.setPassword:
        return _page(ZayRoutes.setPassword, const SetPassword());
      case ZayRoutes.completeProfile:
        return _page(ZayRoutes.completeProfile, const CompleteProfile());
      case ZayRoutes.locationAccess:
        return _page(ZayRoutes.locationAccess, const LocationAccess());
      case ZayRoutes.locationPage:
        return _page(ZayRoutes.locationPage, const LocationPage());
      case ZayRoutes.home:
        return _page(ZayRoutes.home, const HomeScreen());
      case ZayRoutes.productDetails:
        return _page(ZayRoutes.productDetails, const ProductDetails());
      case ZayRoutes.wishlist:
        return _page(ZayRoutes.wishlist, const WishlistScreen());
      default:
        return _page('404', const ErrorScreen(code: 404));
    }
  }
}
