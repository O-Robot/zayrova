import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with RouteAware {
  final List<_NavItem> _navItems = [
    _NavItem(label: 'Home', icon: ZayIcons.homeIcon, route: ZayRoutes.home),
    _NavItem(
      label: 'My Order',
      icon: ZayIcons.orderIcon,
      route: ZayRoutes.orders,
    ),
    _NavItem(
      label: 'Favorite',
      icon: ZayIcons.wishlistIcon,
      route: ZayRoutes.wishlist,
    ),
    _NavItem(
      label: 'My Profile',
      icon: ZayIcons.profileIcon,
      route: ZayRoutes.profile,
    ),
  ];

  String _currentRoute = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null && currentRoute != _currentRoute) {
      setState(() {
        _currentRoute = currentRoute;
      });
    }
    // print('Route: $_currentRoute');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 25, left: 10, right: 10, top: 15),
      decoration: BoxDecoration(
        color: ZayColors.white,
        // border: Border(top: const BorderSide(color: ZayColors.textSecondary)),
        boxShadow: [
          BoxShadow(
            color: ZayColors.textSecondary.withValues(alpha: 0.15),
            offset: const Offset(0, -5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            _navItems.map((item) {
              final isActive = item.route == _currentRoute;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_currentRoute != item.route) {
                      ZayRouter.goto(item.route);
                      setState(() {
                        _currentRoute = item.route;
                      });
                      // print('Current: $_currentRoute');
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      SvgPicture.asset(
                        item.icon,
                        colorFilter: ColorFilter.mode(
                          isActive
                              ? ZayColors.primary
                              : ZayColors.textSecondary.withAlpha(80),
                          BlendMode.srcIn,
                        ),
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZayTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                              color:
                                  isActive
                                      ? ZayColors.primary
                                      : ZayColors.textSecondary,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String icon;
  final String route;

  _NavItem({required this.label, required this.icon, required this.route});
}
