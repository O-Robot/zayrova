import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart'; // Assuming you're using GoRouter for navigation

class NavigationDots extends StatelessWidget {
  final int length;
  final int currentPage;

  const NavigationDots({
    super.key,
    required this.length,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 16 : 11,
          height: isActive ? 16 : 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive
                    ? ZayColors.primary
                    : ZayColors.textPrimary.withAlpha(80),
          ),
        );
      }),
    );
  }
}
