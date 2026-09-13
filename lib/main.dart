import 'package:flutter/material.dart';
import 'screens/log_in_screen.dart';

void main() {
  runApp(const VectorApp());
}

class VectorApp extends StatelessWidget {
  const VectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F4F8),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF493252),
          brightness: Brightness.light,
        ),
      ),
      home: const LogInScreen(),
    );
  }
}
