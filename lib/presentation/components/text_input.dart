import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';

class TextInput extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Widget? trailingIcon;
  final TextInputType type;
  final TextInputAction action;
  final TextEditingController? controller;
  final TextAlign align;
  final bool password;
  final int? maxLines;
  final int? maxLength;
  final double height;
  final double fontSize;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double borderRadius;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final Color border;
  const TextInput({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.controller,
    this.type = TextInputType.text,
    this.align = TextAlign.left,
    this.action = TextInputAction.done,
    this.password = false,
    this.maxLines = 1,
    this.maxLength,
    this.height = 50,
    this.fontSize = 14,
    this.color = const Color(0XFF000000),
    this.backgroundColor = const Color(0XFFF6F6F6),
    this.margin,
    this.padding,
    this.borderRadius = 10,
    this.onChanged,
    this.onSubmitted,
    this.border = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border),
      ),

      child: TextField(
        controller: controller,
        autofocus: false,
        textAlign: align,
        textAlignVertical: TextAlignVertical.center,

        obscureText: password,
        keyboardType: type,
        textInputAction: action,
        maxLines: maxLines,
        style: TextStyle(fontSize: fontSize, color: color),

        decoration: InputDecoration(
          counterText: "",
          contentPadding: padding ?? const EdgeInsets.all(15),
          prefixIcon:
              icon != null
                  ? SizedBox(
                    width: 20,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 2,
                          left: 0,
                          child: Padding(
                            padding: padding ?? const EdgeInsets.all(15),
                            child: icon ?? const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  )
                  : null,
          suffixIcon: trailingIcon,
          hintText: label,
          hintStyle: TextStyle(
            fontSize: fontSize,
            color: ZayColors.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),

        onChanged: onChanged,
        maxLength: maxLength,
        onSubmitted: onSubmitted, /////////////////
      ),
    );
  }
}
