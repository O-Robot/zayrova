import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';

class ZayButton {
  static Widget primary({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
  }) {
    return ElevatedButton(
      onPressed: (isDisabled ?? false) ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (isDisabled ?? false)
                ? ZayColors.primary.withAlpha(80)
                : ZayColors.primary,
        minimumSize: const Size(300, 56),
        maximumSize: const Size(300, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color:
              (isDisabled ?? false) ? ZayColors.textSecondary : ZayColors.white,
        ),
      ),
    );
  }

  static Widget icon({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
  }) {
    return ElevatedButton(
      onPressed: (isDisabled ?? false) ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (isDisabled ?? false)
                ? ZayColors.primary.withAlpha(80)
                : ZayColors.primary,
        minimumSize: const Size(300, 56),
        maximumSize: const Size(300, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            ZayIcons.orderIcon,
            colorFilter: ColorFilter.mode(ZayColors.white, BlendMode.srcIn),
            width: 24,
            height: 24,
          ),
          SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  (isDisabled ?? false)
                      ? ZayColors.textSecondary
                      : ZayColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget cancel({
    required VoidCallback action,
    String? text,
    bool? isDisabled,
  }) {
    return ElevatedButton(
      onPressed: (isDisabled ?? false) ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (isDisabled ?? false)
                ? ZayColors.cancel.withAlpha(80)
                : ZayColors.cancel,
        minimumSize: const Size(300, 56),
        maximumSize: const Size(300, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: Text(
        text ?? 'Cancel',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color:
              (isDisabled ?? false)
                  ? ZayColors.textSecondary
                  : ZayColors.textPrimary,
        ),
      ),
    );
  }
}
