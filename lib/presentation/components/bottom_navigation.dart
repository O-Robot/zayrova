import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart'; // Assuming you have a routes file

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<_NavItem> _navItems = [
    _NavItem(icon: ZayIcons.homeIcon, route: ZayRoutes.home),
    _NavItem(icon: ZayIcons.orderIcon, route: ZayRoutes.orders),
    _NavItem(icon: ZayIcons.wishlistIcon, route: ZayRoutes.wishlist),
    _NavItem(icon: ZayIcons.chatIcon, route: ZayRoutes.chat),
    _NavItem(icon: ZayIcons.profileIcon, route: ZayRoutes.profile),
  ];

  String _currentRoute = ZayRoutes.home;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeName = ModalRoute.of(context)?.settings.name;
    _currentRoute =
        (routeName != null && routeName.isNotEmpty)
            ? routeName
            : ZayRoutes.home;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      decoration: BoxDecoration(
        color: ZayColors.primary,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            _navItems.map((item) {
              final isActive = item.route == _currentRoute;

              return GestureDetector(
                onTap: () {
                  if (_currentRoute != item.route) {
                    ZayRouter.goto(item.route);
                    setState(() {
                      _currentRoute = item.route;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? ZayColors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),

                  child: SvgPicture.asset(
                    item.icon,
                    colorFilter: ColorFilter.mode(
                      isActive ? ZayColors.primary : ZayColors.white,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _NavItem {
  final dynamic icon;
  final String route;

  _NavItem({required this.icon, required this.route});
}
