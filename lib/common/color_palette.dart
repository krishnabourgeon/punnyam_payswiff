import 'package:flutter/material.dart';

class ColorPalette {
  static Color get primaryColor => const Color(0xFFe97c7c);
  static Color get orange => const Color(0xFFf09477);
  static Color get grey => const Color(0xFFd5d7e9);
  static Color get lightGrey => const Color(0xFFF7F7F7);
  static const MaterialColor materialTheme = MaterialColor(
    0xFFe97c7c,
    <int, Color>{
      50: Color(0xFFe97c7c),
      100: Color(0xFFe97c7c),
      200: Color(0xFFe97c7c),
      300: Color(0xFFe97c7c),
      400: Color(0xFFe97c7c),
      500: Color(0xFFe97c7c),
      600: Color(0xFFe97c7c),
      700: Color(0xFFe97c7c),
      800: Color(0xFFe97c7c),
      900: Color(0xFFe97c7c),
    },
  );
}
