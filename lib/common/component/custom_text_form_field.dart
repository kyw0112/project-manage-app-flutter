import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    this.onChanged,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseBorder = OutlineInputBorder(
        borderSide: BorderSide(
      width: 1.0,
    ));

    return TextFormField(
      controller: controller,
      cursorColor: colorScheme.primary,
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontSize: 14.0,
        ),
        fillColor: enabled ? colorScheme.surface : colorScheme.surface.withOpacity(0.5),
        filled: true,
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: colorScheme.error,
            width: 2.0,
          ),
        ),
        disabledBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}
