import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/game_state_provider.dart';
import 'controller/theme_provider.dart';
import 'view/game_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameStateProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Add ThemeProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: GamePage(),
    );
  }
}
