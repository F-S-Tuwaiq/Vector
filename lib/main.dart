import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'screens/home_page.dart';
import 'screens/log_in_screen.dart';
import 'screens/splash_screen.dart';

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
      title: 'Vector',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
      ),
      home: VectorSplash(
        speedFactor: 0.92,
        onComplete: () {
          navigatorKey.currentState?.pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LogInScreen(
                    onSignIn: (email, password) async {
                      navigatorKey.currentState?.pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
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
