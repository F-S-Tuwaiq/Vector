import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'screens/log_in_screen.dart';
import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';

// Show login during local debug runs. Release builds restore the saved session.
const bool _showLoginWhileTesting =
    kDebugMode &&
    bool.fromEnvironment('SHOW_LOGIN_ON_START', defaultValue: true);

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(const VectorApp());
}

Widget _postSplashDestination() {
  return !_showLoginWhileTesting && SupabaseService.isLoggedIn
      ? const RootShell()
      : LogInScreen(onSignIn: SupabaseService.signIn);
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
            MaterialPageRoute(builder: (_) => _postSplashDestination()),
          );
        },
      ),
    );
  }
}
