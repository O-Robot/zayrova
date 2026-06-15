import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';

class ZayLoadingState extends StatelessWidget {
  const ZayLoadingState({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(24),
  });

  final String? message;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: ZayColors.primary),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
