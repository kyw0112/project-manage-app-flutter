// import 'package:flutter/material.dart';
// import 'package:material_color_utilities/material_color_utilities.dart';
// class KeyColor {
//   static Color primary = const Color(0xFF0084AA);
//   static Color secondary = const Color(0xFF81939E);
//   static Color tertiary = const Color(0xFFE0F0FF);
//   static Color neutral = const Color(0xFF8F9193);
//   static Color neutralVariant = const Color(0xFF8B9296);
//   static Color error = const Color(0xFFFF5449);
// }
//
// extension Material3Palette on Color {
//   Color tone(int tone) {
//     assert(tone >= 0 && tone <= 100);
//     final color = Hct.fromInt(value);
//     final tonalPalette = TonalPalette.of(color.hue, color.chroma);
//     return Color(tonalPalette.get(tone));
//   }
// }
//
// ThemeData lightTheme = ThemeData(
//   useMaterial3: true,
//   scaffoldBackgroundColor: Colors.white,
//   colorScheme: ColorScheme(
//     brightness: Brightness.light,
//     primary: Color(0xff003b4e),
//     surfaceTint: Color(0xff006685),
//     onPrimary: Color(0xffffffff),
//     primaryContainer: Color(0xff007698),
//     onPrimaryContainer: Color(0xffffffff),
//     secondary: Color(0xff183a48),
//     onSecondary: Color(0xffffffff),
//     secondaryContainer: Color(0xff517181),
//     onSecondaryContainer: Color(0xffffffff),
//     tertiary: Color(0xff293843),
//     onTertiary: Color(0xffffffff),
//     tertiaryContainer: Color(0xff606f7c),
//     onTertiaryContainer: Color(0xffffffff),
//     error: Color(0xff740006),
//     onError: Color(0xffffffff),
//     errorContainer: Color(0xffcf2c27),
//     onErrorContainer: Color(0xffffffff),
//     surface: Color(0xfff6fafd),
//     onSurface: Color(0xff0d1214),
//     onSurfaceVariant: Color(0xff2e383d),
//     outline: Color(0xff4a5459),
//     outlineVariant: Color(0xff656e74),
//     shadow: Color(0xff000000),
//     scrim: Color(0xff000000),
//     inverseSurface: Color(0xff2d3134),
//     inversePrimary: Color(0xff74d2fb),
//     primaryFixed: Color(0xff007698),
//     onPrimaryFixed: Color(0xffffffff),
//     primaryFixedDim: Color(0xff005c78),
//     onPrimaryFixedVariant: Color(0xffffffff),
//     secondaryFixed: Color(0xff517181),
//     onSecondaryFixed: Color(0xffffffff),
//     secondaryFixedDim: Color(0xff395968),
//     onSecondaryFixedVariant: Color(0xffffffff),
//     tertiaryFixed: Color(0xff606f7c),
//     onTertiaryFixed: Color(0xffffffff),
//     tertiaryFixedDim: Color(0xff485763),
//     onTertiaryFixedVariant: Color(0xffffffff),
//     surfaceDim: Color(0xffc3c7ca),
//     surfaceBright: Color(0xfff6fafd),
//     surfaceContainerLowest: Color(0xffffffff),
//     surfaceContainerLow: Color(0xfff1f4f7),
//     surfaceContainer: Color(0xffe5e9ec),
//     surfaceContainerHigh: Color(0xffdadde0),
//     surfaceContainerHighest: Color(0xffced2d5),
//   ),
// );