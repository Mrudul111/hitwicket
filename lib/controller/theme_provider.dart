import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Color get player1Color {
    return _themeMode == ThemeMode.light ? Colors.blue : Colors.cyan;
  }

  Color get player2Color {
    return _themeMode == ThemeMode.light ? Colors.green : Colors.purple;
  }

  Color get selectionColor {
    return _themeMode == ThemeMode.light ? Colors.yellow : Colors.cyanAccent;
  }
}

