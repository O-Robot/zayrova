import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';

class ZayButton {
  static Widget primary({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    return _base(
      action: action,
      text: text,
      backgroundColor: ZayColors.primary,
      foregroundColor: ZayColors.white,
      disabledBackgroundColor: ZayColors.primary.withAlpha(80),
      disabledForegroundColor: ZayColors.textSecondary,
      isDisabled: isDisabled,
      isLoading: isLoading,
      fullWidth: fullWidth,
      compact: compact,
    );
  }

  static Widget icon({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    final disabled = isDisabled ?? false;
    final height = compact ? 44.0 : 56.0;

    final button = ElevatedButton(
      onPressed: (disabled || isLoading) ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            disabled ? ZayColors.primary.withAlpha(80) : ZayColors.primary,
        minimumSize: Size(fullWidth ? 0 : 300, height),
        maximumSize: fullWidth ? null : Size(300, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ZayColors.white,
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  ZayIcons.orderIcon,
                  colorFilter: const ColorFilter.mode(
                    ZayColors.white,
                    BlendMode.srcIn,
                  ),
                  width: compact ? 20 : 24,
                  height: compact ? 20 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: disabled ? ZayColors.textSecondary : ZayColors.white,
                  ),
                ),
              ],
            ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  static Widget cancel({
    required VoidCallback action,
    String? text,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    return _base(
      action: action,
      text: text ?? 'Cancel',
      backgroundColor: ZayColors.cancel,
      foregroundColor: ZayColors.textPrimary,
      disabledBackgroundColor: ZayColors.cancel.withAlpha(80),
      disabledForegroundColor: ZayColors.textSecondary,
      isDisabled: isDisabled,
      isLoading: isLoading,
      fullWidth: fullWidth,
      compact: compact,
    );
  }

  static Widget secondary({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    return _base(
      action: action,
      text: text,
      backgroundColor: ZayColors.secondary,
      foregroundColor: ZayColors.textPrimary,
      disabledBackgroundColor: ZayColors.secondary.withAlpha(80),
      disabledForegroundColor: ZayColors.textSecondary,
      isDisabled: isDisabled,
      isLoading: isLoading,
      fullWidth: fullWidth,
      compact: compact,
    );
  }

  static Widget outline({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    final disabled = isDisabled ?? false;
    final height = compact ? 44.0 : 56.0;

    final button = OutlinedButton(
      onPressed: (disabled || isLoading) ? null : action,
      style: OutlinedButton.styleFrom(
        foregroundColor: disabled ? ZayColors.textSecondary : ZayColors.primary,
        side: BorderSide(
          color: disabled ? ZayColors.inputBorder : ZayColors.primary,
        ),
        minimumSize: Size(fullWidth ? 0 : 300, height),
        maximumSize: fullWidth ? null : Size(300, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: _buttonChild(
        text: text,
        color: disabled ? ZayColors.textSecondary : ZayColors.primary,
        isLoading: isLoading,
        compact: compact,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  static Widget danger({
    required VoidCallback action,
    required String text,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    const dangerColor = Color(0xFFD32F2F);

    return _base(
      action: action,
      text: text,
      backgroundColor: dangerColor,
      foregroundColor: ZayColors.white,
      disabledBackgroundColor: dangerColor.withAlpha(80),
      disabledForegroundColor: ZayColors.textSecondary,
      isDisabled: isDisabled,
      isLoading: isLoading,
      fullWidth: fullWidth,
      compact: compact,
    );
  }

  static Widget _base({
    required VoidCallback action,
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color disabledBackgroundColor,
    required Color disabledForegroundColor,
    bool? isDisabled,
    bool isLoading = false,
    bool fullWidth = false,
    bool compact = false,
  }) {
    final disabled = isDisabled ?? false;
    final height = compact ? 44.0 : 56.0;

    final button = ElevatedButton(
      onPressed: (disabled || isLoading) ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? disabledBackgroundColor : backgroundColor,
        minimumSize: Size(fullWidth ? 0 : 300, height),
        maximumSize: fullWidth ? null : Size(300, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
      ),
      child: _buttonChild(
        text: text,
        color: disabled ? disabledForegroundColor : foregroundColor,
        isLoading: isLoading,
        compact: compact,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  static Widget _buttonChild({
    required String text,
    required Color color,
    required bool isLoading,
    required bool compact,
  }) {
    if (isLoading) {
      return SizedBox(
        width: compact ? 18 : 20,
        height: compact ? 18 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: compact ? 14 : 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
