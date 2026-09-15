import 'package:flutter/material.dart';

import 'screens/log_in_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  runApp(const _PreviewApp());
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppLauncher(next: LogInScreen()),
    );
  }
}
