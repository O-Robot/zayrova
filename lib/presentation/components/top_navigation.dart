import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';

class TopNavigation extends StatelessWidget {
  final String text;
  const TopNavigation({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            ZayRouter.goBack();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ZayColors.textSecondary),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: ZayColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              text,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
