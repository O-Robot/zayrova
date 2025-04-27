import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/colors.dart';

class SocialButtons {
  static Widget primary(assetPath) {
    return InkWell(
      onTap: () {
        // TODO: Handle social login
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
  }
}
