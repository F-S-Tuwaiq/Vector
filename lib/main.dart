import 'package:flutter/material.dart';

import 'screens/log_in_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/vector_colors.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const VectorApp());
}

class VectorApp extends StatelessWidget {
  const VectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: VectorColors.background,
        fontFamily: 'IBM Plex Sans Arabic',
        colorScheme: ColorScheme.fromSeed(
          seedColor: VectorColors.purpleBrand,
          brightness: Brightness.light,
        ),
      ),
      home: VectorSplash(
        speedFactor: 0.92,
        onComplete: () {
          navigatorKey.currentState?.pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LogInScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) => FadeTransition(opacity: animation, child: child),
            ),
          );
        },
      ),
    );
  }
}
