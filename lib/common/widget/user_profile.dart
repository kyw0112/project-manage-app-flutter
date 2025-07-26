import 'package:flutter/material.dart';

Image basicProfile = Image.asset(
  'assets/img/user/user_basic_icon.png',
  width: 50.0,
  height: 50.0,
  fit: BoxFit.cover,
);

Container profileContainer(
        {required Widget childWidget, double width = 50, double height = 50}) =>
    Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: childWidget,
      ),
    );

Widget customProfile({required String imageUrl, required Widget errorWidget}) =>
    Image.network(
      imageUrl,
      width: 50.0,
      height: 50.0,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget;
      },
    );
