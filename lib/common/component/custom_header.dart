
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final FontWeight? fontWeight;
  final double? fontSize;
  final void Function()? onClicked;
  final String? buttonName;

  const CustomHeader(
      {super.key,
        required this.title,
        this.fontWeight,
        this.fontSize,
        this.onClicked,
        this.buttonName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: fontSize ?? 20,
              fontWeight: fontWeight ?? FontWeight.w500),
        ),
        buttonName != null
            ? TextButton(onPressed: onClicked, child: Text('$buttonName'))
            : SizedBox()
      ],
    );
  }
}
