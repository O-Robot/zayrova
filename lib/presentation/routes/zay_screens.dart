import 'package:flutter/material.dart';
import 'package:zayrova/presentation/pages/auth/complete_profile.dart';
import 'package:zayrova/presentation/pages/auth/sign_up.dart';
import 'package:zayrova/presentation/pages/auth/forgot_password.dart';
import 'package:zayrova/presentation/pages/auth/set_password.dart';
import 'package:zayrova/presentation/pages/auth/verify_email.dart';
import 'package:zayrova/presentation/pages/cart/cart_screen.dart';
import 'package:zayrova/presentation/pages/checkout/add_address_screen.dart';
import 'package:zayrova/presentation/pages/checkout/add_payment_method_screen.dart';
import 'package:zayrova/presentation/pages/checkout/address_list_screen.dart';
import 'package:zayrova/presentation/pages/checkout/checkout_screen.dart';
import 'package:zayrova/presentation/pages/checkout/payment_method_list_screen.dart';
import 'package:zayrova/presentation/pages/checkout/payment_result_screen.dart';
import 'package:zayrova/presentation/pages/home/all_products_screen.dart';
import 'package:zayrova/presentation/pages/home/home_screen.dart';
import 'package:zayrova/presentation/pages/home/category_screen.dart';
import 'package:zayrova/presentation/pages/location/location_access.dart';
import 'package:zayrova/presentation/pages/location/location_page.dart';
import 'package:zayrova/presentation/pages/messages/message_detail_screen.dart';
import 'package:zayrova/presentation/pages/messages/messages_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/get_started_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:zayrova/presentation/pages/onboarding/splash_screen.dart';
import 'package:zayrova/presentation/pages/notifications/notifications_screen.dart';
import 'package:zayrova/presentation/pages/orders/order_details_screen.dart';
import 'package:zayrova/presentation/pages/orders/order_rating_screen.dart';
import 'package:zayrova/presentation/pages/orders/order_review_screen.dart';
import 'package:zayrova/presentation/pages/orders/order_tracking_screen.dart';
import 'package:zayrova/presentation/pages/orders/orders_screen.dart';
import 'package:zayrova/presentation/pages/profile/edit_profile_screen.dart';
import 'package:zayrova/presentation/pages/profile/profile_screen.dart';
import 'package:zayrova/presentation/pages/search/catalog_filter.dart';
import 'package:zayrova/presentation/pages/search/filter_screen.dart';
import 'package:zayrova/presentation/pages/search/search_screen.dart';
import 'package:zayrova/presentation/pages/settings/change_password_screen.dart';
import 'package:zayrova/presentation/pages/settings/help_support_screen.dart';
import 'package:zayrova/presentation/pages/settings/legal_policies_screen.dart';
import 'package:zayrova/presentation/pages/settings/security_screen.dart';
import 'package:zayrova/presentation/pages/settings/settings_screen.dart';
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

  static MaterialPageRoute route(String? route, Map<String, dynamic> data) {
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
        return _page(ZayRoutes.categories, const AllProductsScreen());
      case ZayRoutes.category:
        return _page(
          ZayRoutes.category,
          CategoryScreen(
            categorySlug: data['categorySlug']?.toString(),
            categoryName: data['categoryName']?.toString(),
          ),
        );
      case ZayRoutes.search:
        return _page(ZayRoutes.search, const SearchScreen());
      case ZayRoutes.filter:
        return _page(
          ZayRoutes.filter,
          FilterScreen(
            initialFilters: CatalogFilterValues.fromMap(
              data['filters'] is Map ? data['filters'] as Map : null,
            ),
          ),
        );
      case ZayRoutes.cart:
        return _page(ZayRoutes.cart, const CartScreen());
      case ZayRoutes.checkout:
        return _page(ZayRoutes.checkout, const CheckoutScreen());
      case ZayRoutes.changePaymentMethod:
        return _page(
          ZayRoutes.changePaymentMethod,
          const PaymentMethodListScreen(),
        );
      case ZayRoutes.addPaymentMethod:
        return _page(
          ZayRoutes.addPaymentMethod,
          const AddPaymentMethodScreen(),
        );
      case ZayRoutes.address:
        return _page(ZayRoutes.address, const AddressListScreen());
      case ZayRoutes.addAddress:
        return _page(ZayRoutes.addAddress, const AddAddressScreen());
      case ZayRoutes.paymentSuccess:
        return _page(
          ZayRoutes.paymentSuccess,
          PaymentSuccessScreen(
            orderId: data['orderId']?.toString(),
            orderReference: data['orderReference']?.toString(),
          ),
        );
      case ZayRoutes.paymentFailed:
        return _page(ZayRoutes.paymentFailed, const PaymentFailedScreen());
      case ZayRoutes.orders:
        return _page(ZayRoutes.orders, const OrdersScreen());
      case ZayRoutes.orderHistory:
        return _page(
          ZayRoutes.orderHistory,
          const OrdersScreen(initialTab: 1),
        );
      case ZayRoutes.orderDetails:
        return _page(
          ZayRoutes.orderDetails,
          OrderDetailsScreen(orderId: data['orderId']?.toString()),
        );
      case ZayRoutes.orderTracking:
        return _page(
          ZayRoutes.orderTracking,
          OrderTrackingScreen(orderId: data['orderId']?.toString()),
        );
      case ZayRoutes.orderReview:
        return _page(
          ZayRoutes.orderReview,
          OrderReviewScreen(
            orderId: data is Map ? data['orderId']?.toString() : null,
          ),
        );
      case ZayRoutes.orderRating:
        return _page(
          ZayRoutes.orderRating,
          OrderRatingScreen(
            orderId: data is Map ? data['orderId']?.toString() : null,
          ),
        );
      case ZayRoutes.profile:
        return _page(ZayRoutes.profile, const ProfileScreen());
      case ZayRoutes.settings:
        return _page(ZayRoutes.settings, const SettingsScreen());
      case ZayRoutes.editProfile:
        return _page(ZayRoutes.editProfile, const EditProfileScreen());
      case ZayRoutes.security:
        return _page(ZayRoutes.security, const SecurityScreen());
      case ZayRoutes.changePassword:
        return _page(ZayRoutes.changePassword, const ChangePasswordScreen());
      case ZayRoutes.notifications:
        return _page(ZayRoutes.notifications, const NotificationsScreen());
      case ZayRoutes.messages:
        return _page(ZayRoutes.messages, const MessagesScreen());
      case ZayRoutes.messageDetail:
        return _page(
          ZayRoutes.messageDetail,
          MessageDetailScreen(
            conversationId: data['conversationId']?.toString(),
            title: data['title']?.toString(),
          ),
        );
      case ZayRoutes.helpSupport:
        return _page(ZayRoutes.helpSupport, const HelpSupportScreen());
      case ZayRoutes.legalAndPolicies:
        return _page(ZayRoutes.legalAndPolicies, const LegalPoliciesScreen());
      default:
        return _page('404', const ErrorScreen(code: 404));
    }
  }
}
