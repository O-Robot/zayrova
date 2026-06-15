import 'package:flutter/material.dart';
import 'package:zayrova/presentation/pages/auth/complete_profile.dart';
import 'package:zayrova/presentation/pages/auth/sign_up.dart';
import 'package:zayrova/presentation/pages/auth/forgot_password.dart';
import 'package:zayrova/presentation/pages/auth/set_password.dart';
import 'package:zayrova/presentation/pages/auth/verify_email.dart';
import 'package:zayrova/presentation/pages/cart/cart_screen.dart';
import 'package:zayrova/presentation/pages/checkout/add_address_screen.dart';
import 'package:zayrova/presentation/pages/checkout/address_list_screen.dart';
import 'package:zayrova/presentation/pages/checkout/checkout_screen.dart';
import 'package:zayrova/presentation/pages/home/home_screen.dart';
import 'package:zayrova/presentation/pages/home/category_screen.dart';
import 'package:zayrova/presentation/pages/location/location_access.dart';
import 'package:zayrova/presentation/pages/location/location_page.dart';
import 'package:zayrova/presentation/pages/onboarding/get_started_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/splash_screen.dart';
import 'package:zayrova/presentation/pages/placeholder/placeholder_screen.dart';
import 'package:zayrova/presentation/pages/search/filter_screen.dart';
import 'package:zayrova/presentation/pages/search/search_screen.dart';
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
        return _page(
          ZayRoutes.productDetails,
          ProductDetails(productId: data['productId']?.toString()),
        );
      case ZayRoutes.wishlist:
        return _page(ZayRoutes.wishlist, const WishlistScreen());
      case ZayRoutes.categories:
        return _page(ZayRoutes.categories, const CategoryScreen());
      case ZayRoutes.category:
        return _page(
          ZayRoutes.category,
          CategoryScreen(
            categorySlug: data['categorySlug']?.toString(),
            categoryName: data['categoryName']?.toString(),
          ),
        );
      case ZayRoutes.categoryDetails:
        return _placeholder(ZayRoutes.categoryDetails, 'Category Details');
      case ZayRoutes.search:
        return _page(ZayRoutes.search, const SearchScreen());
      case ZayRoutes.filter:
        return _page(ZayRoutes.filter, const FilterScreen());
      case ZayRoutes.cart:
        return _page(ZayRoutes.cart, const CartScreen());
      case ZayRoutes.checkout:
      case ZayRoutes.payment:
        return _page(route ?? ZayRoutes.checkout, const CheckoutScreen());
      case ZayRoutes.orderSummary:
        return _placeholder(ZayRoutes.orderSummary, 'Order Summary');
      case ZayRoutes.changePaymentMethod:
        return _placeholder(
          ZayRoutes.changePaymentMethod,
          'Change Payment Method',
        );
      case ZayRoutes.address:
        return _page(ZayRoutes.address, const AddressListScreen());
      case ZayRoutes.addAddress:
        return _page(ZayRoutes.addAddress, const AddAddressScreen());
      case ZayRoutes.paymentSuccess:
        return _placeholder(ZayRoutes.paymentSuccess, 'Payment Success');
      case ZayRoutes.paymentFailed:
        return _placeholder(ZayRoutes.paymentFailed, 'Payment Failed');
      case ZayRoutes.orders:
        return _placeholder(ZayRoutes.orders, 'My Order');
      case ZayRoutes.orderHistory:
        return _placeholder(ZayRoutes.orderHistory, 'Order History');
      case ZayRoutes.orderDetails:
        return _placeholder(ZayRoutes.orderDetails, 'Order Detail');
      case ZayRoutes.orderTracking:
        return _placeholder(ZayRoutes.orderTracking, 'Order Tracking');
      case ZayRoutes.orderReview:
        return _placeholder(ZayRoutes.orderReview, 'Order Review');
      case ZayRoutes.orderRating:
        return _placeholder(ZayRoutes.orderRating, 'Order Rating');
      case ZayRoutes.profile:
        return _placeholder(ZayRoutes.profile, 'My Profile');
      case ZayRoutes.settings:
        return _placeholder(ZayRoutes.settings, 'Settings');
      case ZayRoutes.notifications:
        return _placeholder(ZayRoutes.notifications, 'Notifications');
      case ZayRoutes.chat:
      case ZayRoutes.messages:
        return _placeholder(ZayRoutes.messages, 'Messages');
      case ZayRoutes.messageDetail:
        return _placeholder(ZayRoutes.messageDetail, 'Message Detail');
      case ZayRoutes.helpSupport:
        return _placeholder(ZayRoutes.helpSupport, 'Help and Support');
      case ZayRoutes.legalAndPolicies:
        return _placeholder(ZayRoutes.legalAndPolicies, 'Legal and Policies');
      default:
        return _page('404', const ErrorScreen(code: 404));
    }
  }

  static MaterialPageRoute _placeholder(String route, String title) {
    return _page(route, PlaceholderScreen(title: title));
  }
}
