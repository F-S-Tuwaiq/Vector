import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
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
      title: 'Vector',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
        ),
      ),
      home: const LogInScreen(),
    );
  }
}