import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Color _winTextColor = Colors.green; // Default color for win text

  Color get winTextColor => _winTextColor;

  void setWinTextColor(Color color) {
    _winTextColor = color;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get themeData {
    if (_themeMode == ThemeMode.light) {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: Colors.green,
        ),
      );
    } else {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        colorScheme: ColorScheme.dark(
          primary: Colors.cyan,
          onPrimary: Colors.black,
          secondary: Colors.purple,
        ),
      );
    }
  }

  Color get player1Color {
    return themeData.colorScheme.primary;
  }

  Color get player2Color {
    return themeData.colorScheme.secondary;
  }

  Color get selectionColor {
    return _themeMode == ThemeMode.light ? Colors.yellow : Colors.cyanAccent;
  }
}
