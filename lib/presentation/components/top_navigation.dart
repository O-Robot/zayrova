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
          onTap: () => ZayRouter.goBack(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.chevron_left,
                color: ZayColors.textPrimary,
                size: 36,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
