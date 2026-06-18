import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/colors.dart';

class SocialButtons {
  static Widget primary(assetPath) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Social authentication is coming soon.'),
                backgroundColor: ZayColors.primary,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ZayColors.textSecondary),
            ),
            child: SvgPicture.asset(assetPath, width: 24, height: 24),
          ),
        );
      },
    );
  }
}
