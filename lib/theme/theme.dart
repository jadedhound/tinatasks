import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tinatasks/service/services.dart';
import 'package:tinatasks/theme/constants.dart';

class ThemeModel with ChangeNotifier {
  FlutterThemeMode _themeMode = FlutterThemeMode.dark;
  FlutterThemeMode get themeMode => _themeMode;

  void set themeMode(FlutterThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_themeMode) {
      case FlutterThemeMode.dark:
        return buildVikunjaDarkTheme();
      case FlutterThemeMode.materialYouLight:
        return buildVikunjaMaterialLightTheme();
      case FlutterThemeMode.materialYouDark:
        return buildVikunjaMaterialDarkTheme();
      default:
        return buildVikunjaTheme();
    }
  }

  ThemeData getWithColorScheme(
      ColorScheme? lightTheme, ColorScheme? darkTheme) {
    switch (_themeMode) {
      case FlutterThemeMode.dark:
        return buildVikunjaDarkTheme().copyWith(colorScheme: darkTheme);
      case FlutterThemeMode.materialYouLight:
        return buildVikunjaMaterialLightTheme()
            .copyWith(colorScheme: lightTheme);
      case FlutterThemeMode.materialYouDark:
        return buildVikunjaMaterialDarkTheme().copyWith(colorScheme: darkTheme);
      default:
        return buildVikunjaTheme().copyWith(colorScheme: lightTheme);
    }
  }
}

ThemeData buildVikunjaTheme() => _buildVikunjaTheme(ThemeData.light());
ThemeData buildVikunjaDarkTheme() =>
    _buildVikunjaTheme(ThemeData.dark(), isDark: true);

ThemeData buildVikunjaMaterialLightTheme() {
  return ThemeData.light().copyWith();
}

ThemeData buildVikunjaMaterialDarkTheme() {
  return ThemeData.dark().copyWith();
}

ThemeData _buildVikunjaTheme(ThemeData base, {bool isDark = false}) {
  return base.copyWith(
    primaryColor: vPrimaryDark,
    primaryColorLight: vPrimary,
    primaryColorDark: vBlueDark,
    colorScheme: base.colorScheme.copyWith(
      primary: vPrimaryDark,
      secondary: vPrimary,
      error: vRed,
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      foregroundColor: vWhite,
    ),
    textTheme: base.textTheme.copyWith(
//      headline: base.textTheme.headline.copyWith(
//        fontFamily: 'Quicksand',
//      ),
//      title: base.textTheme.title.copyWith(
//        fontFamily: 'Quicksand',
//      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        color:
            vWhite, // This does not work, looks like a bug in Flutter: https://github.com/flutter/flutter/issues/19623
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1)),
    ),
    dividerTheme: DividerThemeData(
      color: () {
        return isDark ? Colors.white10 : Colors.black12;
      }(),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      indicatorColor: vPrimary,
      // Make bottomNavigationBar backgroundColor darker to provide more separation
      backgroundColor: () {
        final _hslColor = HSLColor.fromColor(
            base.bottomNavigationBarTheme.backgroundColor ??
                base.scaffoldBackgroundColor);
        return _hslColor
            .withLightness(max(_hslColor.lightness - 0.03, 0))
            .toColor();
      }(),
    ),
  );
}
