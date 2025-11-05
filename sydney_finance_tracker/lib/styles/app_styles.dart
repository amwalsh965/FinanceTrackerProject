import 'package:flutter/material.dart';

class AppStyles {
  static const Color primary = Colors.blue;
  static const double padding = 16.0;
  static const double buttonHeight = 50.0;
  static final Color? backgroundColor = Colors.pink[100];
  static const Color textColor = Colors.white;
  static final Color? borderColor = Colors.pink[300];
  static const double iconSize = 90;

  static final Color? _menuButtonBackgroundColor = Colors.pink[200];
  static final Color? _menuButtonForegroundColor = Colors.green[50];

  static final Color? _menuButtonPressed = Colors.pink[500];
  static final Color? _menuButtonHover = Colors.pink[300];

  static final ButtonStyle menuButtonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    foregroundColor: _menuButtonForegroundColor,
    backgroundColor: _menuButtonBackgroundColor,
  ).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return _menuButtonPressed ?? Colors.pink;
        } else if (states.contains(WidgetState.hovered)) {
          return _menuButtonHover ?? Colors.pink;
        }
        return _menuButtonBackgroundColor ?? Colors.pink;
      },
    ),
  );
}
