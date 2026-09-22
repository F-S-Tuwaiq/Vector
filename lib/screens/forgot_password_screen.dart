import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../widgets/login_style_header.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});
  final String initialEmail;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SingleChildScrollView(
      child: Column(
        children: [
          LoginStyleHeader(onBack: () => Navigator.pop(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 32, 35, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Forgot your password?', style: AppTypography.display()),
                const SizedBox(height: 16),
                Text(
                  'Password reset is not available yet. Please contact the Vector team for help.',
                  style: AppTypography.sans(
                    size: 14,
                    color: AppColors.muted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
