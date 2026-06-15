import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    IconData? prefixIcon,
    dynamic leadingIconS,
    IconData? trailingIcon,
    IconData? suffixIcon,
    dynamic trailingIconS,
    VoidCallback? onTrailingIconTap,
    String? helperText,
    String? validationText,
    int maxLines = 1,
    int maxLength = 255,
    double height = 50,
    bool password = false,
    TextAlign textAlign = TextAlign.left,
    TextInputType type = TextInputType.text,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
    EdgeInsets? margin,
    Color? border,
  }) {
    final effectiveLeadingIcon = leadingIcon ?? prefixIcon;
    final effectiveTrailingIcon = trailingIcon ?? suffixIcon;
    final hasValidationText =
        validationText != null && validationText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ZayTheme.lightTheme.textTheme.displayMedium),
        const SizedBox(height: 6),
        TextInput(
          label: label,
          controller: controller,
          color: ZayColors.textPrimary,
          height: height,
          backgroundColor: ZayColors.transparent,
          borderRadius: 8,
          border: border ??
              (!hasValidationText
                  ? ZayColors.inputBorder
                  : ZayColors.secondary),
          // Removed invalid parameter 'borderColor'
          maxLength: maxLength,
          type: type,
          icon:
              effectiveLeadingIcon != null
                  ? Icon(effectiveLeadingIcon, size: iconSize)
                  : leadingIconS,
          trailingIcon:
              effectiveTrailingIcon != null
                  ? GestureDetector(
                    onTap: onTrailingIconTap,
                    child: Icon(
                      effectiveTrailingIcon,
                      color: ZayColors.inputBorder,
                      size: ZayTextInput.iconSize,
                    ),
                  )
                  : trailingIconS != null
                  ? GestureDetector(
                    onTap: onTrailingIconTap,
                    child: trailingIconS,
                  )
                  : null,
          maxLines: maxLines,
          align: textAlign,
          password: password,
          onChanged: onChanged,
          onSubmitted: onSubmit,
          margin: margin,
        ),
        if (hasValidationText) ...[
          const SizedBox(height: 4),
          Text(
            validationText,
            style: ZayTheme.lightTheme.textTheme.displaySmall?.copyWith(
              color: ZayColors.secondary,
            ),
          ),
        ] else if (helperText != null && helperText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: ZayTheme.lightTheme.textTheme.displaySmall?.copyWith(
              color: ZayColors.textSecondary,
            ),
          ),
        ],
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

  static Widget dropdown(
    String label, {
    required List<String> items,
    String? value,
    Function(String? value)? onChanged,
    double height = 50,
    EdgeInsets? margin,
    BuildContext? context,
  }) {
    final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    if (isIOS && context != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ZayTheme.lightTheme.textTheme.displayMedium),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder:
                    (_) => Container(
                      height: 250,
                      color: Colors.white,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                          initialItem: value != null ? items.indexOf(value) : 0,
                        ),
                        onSelectedItemChanged: (index) {
                          onChanged?.call(items[index]);
                        },
                        children:
                            items
                                .map(
                                  (item) => Center(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: ZayColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
              );
            },
            child: Container(
              height: height,
              margin: margin ?? const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: ZayColors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ZayColors.inputBorder),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                value ?? label,
                style: TextStyle(
                  color:
                      value == null
                          ? ZayColors.textSecondary
                          : ZayColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ZayTheme.lightTheme.textTheme.displayMedium),
          const SizedBox(height: 6),
          Container(
            height: height,
            margin: margin ?? const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ZayColors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ZayColors.inputBorder),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              hint: Text(
                label,
                style: TextStyle(color: ZayColors.textSecondary),
              ),
              items:
                  items
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(color: ZayColors.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
              icon: Transform.rotate(
                angle: 1.5708, // Rotate 90 degrees (in radians)
                child: Icon(Icons.chevron_right, color: ZayColors.inputBorder),
              ),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      );
    }
  }
}

class ZayPasswordInput extends StatefulWidget {
  const ZayPasswordInput({
    super.key,
    required this.label,
    this.controller,
    this.helperText,
    this.validationText,
    this.onChanged,
    this.onSubmit,
  });

  final String label;
  final TextEditingController? controller;
  final String? helperText;
  final String? validationText;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmit;

  @override
  State<ZayPasswordInput> createState() => _ZayPasswordInputState();
}

class _ZayPasswordInputState extends State<ZayPasswordInput> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return ZayTextInput.primary(
      widget.label,
      controller: widget.controller,
      password: _isObscured,
      suffixIcon: _isObscured ? Icons.visibility_off : Icons.visibility,
      onTrailingIconTap: () {
        setState(() => _isObscured = !_isObscured);
      },
      helperText: widget.helperText,
      validationText: widget.validationText,
      onChanged: widget.onChanged,
      onSubmit: widget.onSubmit,
    );
  }
}
