import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField(
      {super.key,
      this.hintText,
      this.errorText,
      this.obscureText = false,
      this.autofocus = false,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseBorder = OutlineInputBorder(
        borderSide: BorderSide(
      width: 1.0,
    ));

    return TextFormField(
      cursorColor: colorScheme.primary,
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20),
        hintText: hintText,
        errorText: errorText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14.0,
        ),
        fillColor: colorScheme.surface,
        filled: true,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        // enabledBorder: baseBorder,
        //모든 속성을 그대로 가져오면서 바꾸고 싶은 부분만 수정하고자 할 때
        // baseBorder를 가져와서 borderSide의 color만 변경
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide
              .copyWith(color: colorScheme.primary),
        ),
      ),
    );
  }
}
