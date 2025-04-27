import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/text_input.dart';

class ZayTextInput {
  static double iconSize = 20.0;

  static Widget primary(
    String label, {
    TextEditingController? controller,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onTrailingIconTap,
    int maxLines = 1,
    int maxLength = 255,
    double height = 50,
    bool password = false,
    TextAlign textAlign = TextAlign.left,
    TextInputType type = TextInputType.text,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
    EdgeInsets? margin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ZayTheme.lightTheme.textTheme.displayMedium),
        SizedBox(height: 6),
        TextInput(
          label: label,
          controller: controller,
          color: ZayColors.textPrimary,
          height: height,
          backgroundColor: ZayColors.transparent,
          borderRadius: 8,
          border: ZayColors.inputBorder,
          // Removed invalid parameter 'borderColor'
          maxLength: maxLength,
          type: type,
          icon:
              leadingIcon != null
                  ? Icon(
                    leadingIcon,
                    color: ZayColors.inputBorder,
                    size: ZayTextInput.iconSize,
                  )
                  : null,
          trailingIcon:
              trailingIcon != null
                  ? GestureDetector(
                    onTap: onTrailingIconTap,
                    child: Icon(
                      trailingIcon,
                      color: ZayColors.inputBorder,
                      size: ZayTextInput.iconSize,
                    ),
                  )
                  : null,
          maxLines: maxLines,
          align: textAlign,
          password: password,
          onChanged: onChanged,
          onSubmitted: onSubmit,
          margin: margin,
        ),
      ],
    );
  }

  static Widget secondary(
    String hint, {
    TextEditingController? controller,
    IconData? leadingIcon,
    IconData? trailingIcon,
    int maxLines = 1,
    double height = 50,
    bool password = false,
    TextAlign textAlign = TextAlign.left,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
  }) {
    return TextInput(
      label: hint,
      controller: controller,
      height: height,
      backgroundColor: ZayColors.white,
      borderRadius: 7,
      icon:
          leadingIcon != null
              ? Icon(
                leadingIcon,
                color: Colors.black,
                size: ZayTextInput.iconSize,
              )
              : null,
      trailingIcon:
          trailingIcon != null
              ? Icon(
                trailingIcon,
                color: Colors.black,
                size: ZayTextInput.iconSize,
              )
              : null,
      maxLines: maxLines,
      align: textAlign,
      password: password,
      onChanged: onChanged,
      onSubmitted: onSubmit,
    );
  }
}
