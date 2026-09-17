import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../widgets/login_style_header.dart';

/// Presentation-only reset flow. Intentionally does not send email or call auth.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                LoginStyleHeader(onBack: () => Navigator.pop(context)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 32, 35, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'RESET PASSWORD',
                          style: AppTypography.sans(
                            size: 10,
                            color: AppColors.muted,
                            weight: FontWeight.w600,
                            spacing: 3.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _submitted
                              ? 'Check your email.'
                              : 'Forgot your\npassword?',
                          style: AppTypography.display(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _submitted
                              ? 'Check your email to reset your password.'
                              : 'Enter your email to reset your password.',
                          style: AppTypography.sans(
                            size: 14,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                        if (!_submitted) ...[
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            cursorColor: AppColors.purple,
                            style: AppTypography.sans(
                              size: 14,
                              color: AppColors.muted,
                            ),
                            validator: (value) =>
                                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch((value ?? '').trim())
                                ? null
                                : 'Enter a valid email.',
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'EMAIL',
                              hintText: 'you@example.com',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: AppTypography.sans(
                                size: 10.5,
                                weight: FontWeight.w600,
                                spacing: 2.3,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(
                                  color: AppColors.fieldBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(
                                  color: AppColors.fieldBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(
                                  color: AppColors.fieldFocused,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.apricotButtonStart,
                                  AppColors.apricotButtonEnd,
                                ],
                              ),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.purple,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _submit,
                              child: Text(
                                'Reset password',
                                style: AppTypography.sans(
                                  size: 15,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Back to sign in',
                            style: AppTypography.sans(
                              size: 14,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
