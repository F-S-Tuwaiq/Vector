import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vector/screens/sign_up_screen.dart';

import 'root_shell.dart';
import '../widgets/brand_loader/brand_full_screen_loader.dart';
import '../widgets/signup_code_dialog.dart';
import '../services/supabase_service.dart';
import '../constants/app_constants.dart';
import '../widgets/vector_shapes.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({
    super.key,
    this.onSignIn,
    this.onForgotPassword,
    this.onSignUp,
  });

  final Future<void> Function(String email, String password)? onSignIn;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _entrance;
  late final AnimationController _floating;
  late final Animation<double> _fade;
  bool _started = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _floating = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _entrance.value = 1;
      _floating.stop();
      _started = true;
    } else {
      if (!_started) {
        _started = true;
        _entrance.forward();
      }
      if (!_floating.isAnimating) _floating.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _floating.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (widget.onSignIn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect your authentication to onSignIn.'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      try {
        await runWithBrandFullScreenLoader(
          context,
          () => widget.onSignIn!(_email.text.trim(), _password.text),
          sequence: VLogoSequence.oneVAndWhite,
        );
      } on EmailVerificationRequired {
        if (!mounted) return;
        final verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => SignupCodeDialog(email: _email.text.trim(), password: _password.text),
        );
        if (verified != true) return;
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (mounted) {
        final message = switch (error.code) {
          'invalid_credentials' => 'The email or password is incorrect.',
          'over_request_rate_limit' || 'over_email_send_rate_limit' =>
            'Too many attempts. Please wait a minute and try again.',
          'user_banned' => 'This account is currently disabled.',
          _ => error.message,
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      debugPrint('Login failed (${error.runtimeType}).');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not connect to sign in. Check your internet connection and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth, 460.0);
            final height = width * 736 / 390;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 390,
                        height: 736,
                        child: FadeTransition(opacity: _fade, child: _screen()),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _screen() {
    return Form(
      key: _formKey,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: VectorBackground(animation: _floating),
              ),
            ),
          ),
          Positioned(
            left: 34,
            top: 46,
            child: Semantics(
              label: 'Vector',
              image: true,
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    SizedBox(
                      width: 29,
                      height: 31,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          minWidth: 52,
                          maxWidth: 52,
                          minHeight: 52,
                          maxHeight: 52,
                          child: Image.asset(
                            'assets/logo/vector-mark-dark-1024-removebg-preview.png',
                            width: 52,
                            height: 52,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'ector',
                      style: AppTypography.sans(
                        size: 31,
                        color: AppColors.background,
                        weight: FontWeight.w500,
                        spacing: -1.4,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 234,
            height: 232,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                    child: Text(
                      'WELCOME BACK',
                      style: AppTypography.sans(
                        size: 10,
                        color: AppColors.muted,
                        weight: FontWeight.w600,
                        spacing: 3.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: Text(
                      'From Vision\nto Victory.',
                      style: AppTypography.display(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 18,
                    child: Text(
                      'Sign in to find your team.',
                      style: AppTypography.sans(
                        size: 13.6,
                        color: AppColors.muted,
                        spacing: -0.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 466,
            height: 47,
            child: _input(
              controller: _email,
              label: 'EMAIL',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
              validator: (value) =>
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch((value ?? '').trim())
                  ? null
                  : 'Enter a valid email.',
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 528,
            height: 47,
            child: _input(
              controller: _password,
              label: 'PASSWORD',
              hint: '••••••••',
              password: true,
              action: TextInputAction.done,
              validator: (value) => value == null || value.isEmpty
                  ? 'Enter your password.'
                  : null,
            ),
          ),
          Positioned(
            right: 30,
            top: 562,
            child: TextButton(
              onPressed: _loading ? null : () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                minimumSize: const Size(48, 30),
              ),
              child: Text(
                'Forgot password?',
                style: AppTypography.sans(
                  size: 10.8,
                  weight: FontWeight.w500,
                  spacing: -0.25,
                ),
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 616,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.apricotButtonStart,
                    AppColors.apricotButtonEnd,
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loading ? null : _submit,
                  // No in-button spinner: the full-screen brand loader
                  // takes over the instant this is tapped (see _submit).
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign in',
                          style: AppTypography.sans(
                            size: 15,
                            weight: FontWeight.w500,
                            spacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const SizedBox(
                          width: 12,
                          height: 14,
                          child: CustomPaint(painter: ButtonTrianglePainter()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 680,
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account?',
                  style: AppTypography.sans(
                    size: 14,
                    color: AppColors.muted,
                    spacing: -0.2,
                  ),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SignUpScreen(
                                onCreateAccount: SupabaseService.createAccount,
                              ),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(76, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  child: Text(
                    'Sign up',
                    style: AppTypography.sans(
                      size: 14,
                      color: AppColors.secondary,
                      weight: FontWeight.w500,
                      spacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputAction action,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool password = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      obscureText: password && _obscure,
      obscuringCharacter: '•',
      keyboardType: keyboardType,
      textInputAction: action,
      autocorrect: false,
      enableSuggestions: !password,
      cursorColor: AppColors.purple,
      style: AppTypography.sans(
        size: 13.3,
        color: AppColors.muted,
        spacing: password && _obscure ? 2.5 : -0.3,
      ),
      onFieldSubmitted: (_) {
        if (password) _submit();
      },
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTypography.sans(
          size: 10.5,
          weight: FontWeight.w600,
          spacing: 2.3,
        ),
        floatingLabelStyle: AppTypography.sans(
          size: 10.5,
          weight: FontWeight.w600,
          spacing: 2.3,
        ),
        hintText: hint,
        hintStyle: AppTypography.sans(
          size: 13.3,
          color: AppColors.muted,
          spacing: password ? 2.5 : -0.3,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.13),
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(13, 16, 12, 8),
        errorStyle: const TextStyle(fontSize: 0, height: 0),
        border: _fieldBorder(AppColors.fieldBorder),
        enabledBorder: _fieldBorder(AppColors.fieldBorder),
        focusedBorder: _fieldBorder(AppColors.fieldFocused, width: 1.2),
        errorBorder: _fieldBorder(AppColors.fieldError),
        suffixIcon: password
            ? IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: _loading
                    ? null
                    : () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.mutedDeep,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 0.65}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: color, width: width),
        gapPadding: 0,
      );
}
