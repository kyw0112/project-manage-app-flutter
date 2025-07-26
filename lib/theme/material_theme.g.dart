import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278209680),
      surfaceTint: Color(4278214321),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280643781),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4283064193),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4291550719),
      onSecondaryContainer: Color(4281288037),
      tertiary: Color(4278209644),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280447642),
      onTertiaryContainer: Color(4294967295),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294572543),
      onBackground: Color(4279835681),
      surface: Color(4294572543),
      onSurface: Color(4279835681),
      surfaceVariant: Color(4292731632),
      onSurfaceVariant: Color(4282468178),
      outline: Color(4285691779),
      outlineVariant: Color(4290889427),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inverseOnSurface: Color(4293914872),
      inversePrimary: Color(4289120511),
      primaryFixed: Color(4292207615),
      onPrimaryFixed: Color(4278197307),
      primaryFixedDim: Color(4289120511),
      onPrimaryFixedVariant: Color(4278208391),
      secondaryFixed: Color(4292207615),
      onSecondaryFixed: Color(4278262842),
      secondaryFixedDim: Color(4289841390),
      onSecondaryFixedVariant: Color(4281485160),
      tertiaryFixed: Color(4291291135),
      onTertiaryFixed: Color(4278197806),
      tertiaryFixedDim: Color(4287221500),
      onTertiaryFixedVariant: Color(4278209644),
      surfaceDim: Color(4292401889),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112251),
      surfaceContainer: Color(4293717493),
      surfaceContainerHigh: Color(4293322991),
      surfaceContainerHighest: Color(4292993770),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278207360),
      surfaceTint: Color(4278214321),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280643781),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281222244),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284511640),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278208614),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280447642),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294572543),
      onBackground: Color(4279835681),
      surface: Color(4294572543),
      onSurface: Color(4279835681),
      surfaceVariant: Color(4292731632),
      onSurfaceVariant: Color(4282205006),
      outline: Color(4284112746),
      outlineVariant: Color(4285889415),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inverseOnSurface: Color(4293914872),
      inversePrimary: Color(4289120511),
      primaryFixed: Color(4281103818),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278213804),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284511640),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282867070),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4281367461),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278280842),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292401889),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112251),
      surfaceContainer: Color(4293717493),
      surfaceContainerHigh: Color(4293322991),
      surfaceContainerHighest: Color(4292993770),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278198855),
      surfaceTint: Color(4278214321),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278207360),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4278788673),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4281222244),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278199607),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278208614),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294572543),
      onBackground: Color(4279835681),
      surface: Color(4294572543),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292731632),
      onSurfaceVariant: Color(4280165422),
      outline: Color(4282205006),
      outlineVariant: Color(4282205006),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4293192959),
      primaryFixed: Color(4278207360),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278201689),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4281222244),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4279643468),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278208614),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278202438),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292401889),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112251),
      surfaceContainer: Color(4293717493),
      surfaceContainerHigh: Color(4293322991),
      surfaceContainerHighest: Color(4292993770),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4289120511),
      surfaceTint: Color(4289120511),
      onPrimary: Color(4278202464),
      primaryContainer: Color(4278212772),
      onPrimaryContainer: Color(4294966527),
      secondary: Color(4289841390),
      onSecondary: Color(4279906640),
      secondaryContainer: Color(4280761693),
      onSecondaryContainer: Color(4290499064),
      tertiary: Color(4287221500),
      onTertiary: Color(4278203468),
      tertiaryContainer: Color(4278212476),
      onTertiaryContainer: Color(4293457151),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279309081),
      onBackground: Color(4292993770),
      surface: Color(4279309081),
      onSurface: Color(4292993770),
      surfaceVariant: Color(4282468178),
      onSurfaceVariant: Color(4290889427),
      outline: Color(4287336861),
      outlineVariant: Color(4282468178),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292993770),
      inverseOnSurface: Color(4281217078),
      inversePrimary: Color(4278214321),
      primaryFixed: Color(4292207615),
      onPrimaryFixed: Color(4278197307),
      primaryFixedDim: Color(4289120511),
      onPrimaryFixedVariant: Color(4278208391),
      secondaryFixed: Color(4292207615),
      onSecondaryFixed: Color(4278262842),
      secondaryFixedDim: Color(4289841390),
      onSecondaryFixedVariant: Color(4281485160),
      tertiaryFixed: Color(4291291135),
      onTertiaryFixed: Color(4278197806),
      tertiaryFixedDim: Color(4287221500),
      onTertiaryFixedVariant: Color(4278209644),
      surfaceDim: Color(4279309081),
      surfaceBright: Color(4281743679),
      surfaceContainerLowest: Color(4278914579),
      surfaceContainerLow: Color(4279835681),
      surfaceContainer: Color(4280098853),
      surfaceContainerHigh: Color(4280756784),
      surfaceContainerHighest: Color(4281480507),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4289645823),
      surfaceTint: Color(4289120511),
      onPrimary: Color(4278195762),
      primaryContainer: Color(4283470569),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4290170099),
      onSecondary: Color(4278195762),
      secondaryContainer: Color(4286354102),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4287615743),
      onTertiary: Color(4278196262),
      tertiaryContainer: Color(4283537603),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279309081),
      onBackground: Color(4292993770),
      surface: Color(4279309081),
      onSurface: Color(4294703871),
      surfaceVariant: Color(4282468178),
      onSurfaceVariant: Color(4291218392),
      outline: Color(4288586671),
      outlineVariant: Color(4286481295),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292993770),
      inverseOnSurface: Color(4280756784),
      inversePrimary: Color(4278208649),
      primaryFixed: Color(4292207615),
      onPrimaryFixed: Color(4278194473),
      primaryFixedDim: Color(4289120511),
      onPrimaryFixedVariant: Color(4278204010),
      secondaryFixed: Color(4292207615),
      onSecondaryFixed: Color(4278194473),
      secondaryFixedDim: Color(4289841390),
      onSecondaryFixedVariant: Color(4280301398),
      tertiaryFixed: Color(4291291135),
      onTertiaryFixed: Color(4278194975),
      tertiaryFixedDim: Color(4287221500),
      onTertiaryFixedVariant: Color(4278205012),
      surfaceDim: Color(4279309081),
      surfaceBright: Color(4281743679),
      surfaceContainerLowest: Color(4278914579),
      surfaceContainerLow: Color(4279835681),
      surfaceContainer: Color(4280098853),
      surfaceContainerHigh: Color(4280756784),
      surfaceContainerHighest: Color(4281480507),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294703871),
      surfaceTint: Color(4289120511),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289645823),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294703871),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290170099),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294507519),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4287615743),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279309081),
      onBackground: Color(4292993770),
      surface: Color(4279309081),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282468178),
      onSurfaceVariant: Color(4294703871),
      outline: Color(4291218392),
      outlineVariant: Color(4291218392),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292993770),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278200916),
      primaryFixed: Color(4292667391),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289645823),
      onPrimaryFixedVariant: Color(4278195762),
      secondaryFixed: Color(4292667391),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290170099),
      onSecondaryFixedVariant: Color(4278195762),
      tertiaryFixed: Color(4291881727),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4287615743),
      onTertiaryFixedVariant: Color(4278196262),
      surfaceDim: Color(4279309081),
      surfaceBright: Color(4281743679),
      surfaceContainerLowest: Color(4278914579),
      surfaceContainerLow: Color(4279835681),
      surfaceContainer: Color(4280098853),
      surfaceContainerHigh: Color(4280756784),
      surfaceContainerHighest: Color(4281480507),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );

  /// Custom Color
  static const customColor = ExtendedColor(
    seed: Color(4282351303),
    value: Color(4282351303),
    light: ColorFamily(
      color: Color(4278210963),
      onColor: Color(4294967295),
      colorContainer: Color(4281759423),
      onColorContainer: Color(4294967295),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4278210963),
      onColor: Color(4294967295),
      colorContainer: Color(4281759423),
      onColorContainer: Color(4294967295),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4278210963),
      onColor: Color(4294967295),
      colorContainer: Color(4281759423),
      onColorContainer: Color(4294967295),
    ),
    dark: ColorFamily(
      color: Color(4288924159),
      onColor: Color(4278202717),
      colorContainer: Color(4281628093),
      onColorContainer: Color(4294967295),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4288924159),
      onColor: Color(4278202717),
      colorContainer: Color(4281628093),
      onColorContainer: Color(4294967295),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4288924159),
      onColor: Color(4278202717),
      colorContainer: Color(4281628093),
      onColorContainer: Color(4294967295),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor,
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
