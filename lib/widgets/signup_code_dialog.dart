import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../services/supabase_service.dart';

class SignupCodeDialog extends StatefulWidget {
  const SignupCodeDialog({
    super.key,
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  State<SignupCodeDialog> createState() => _SignupCodeDialogState();
}

class _SignupCodeDialogState extends State<SignupCodeDialog> {
  bool _busy = false;
  String? _message;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendSeconds--);
      if (_resendSeconds == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit({bool resend = false}) async {
    if (_busy || (resend && _resendSeconds > 0)) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (resend) {
        _startResendCooldown();
        await SupabaseService.resendSignupCode(widget.email);
        if (mounted) {
          setState(() => _message = 'A new confirmation email has been sent.');
        }
      } else {
        await SupabaseService.signIn(widget.email, widget.password);
        if (mounted) Navigator.of(context).pop(true);
      }
    } on EmailVerificationRequired {
      if (mounted) {
        setState(
          () => _message = 'Your email is not confirmed yet. Open the confirmation link in your email, then return here.',
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(
          () => _message =
              error.statusCode == '429' ||
                  error.code == 'over_email_send_rate_limit' ||
                  error.code == 'over_request_rate_limit'
              ? 'The email or request limit has been reached. Please wait until it resets before trying again.'
              : error.message,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = resend
              ? 'Could not send the email. Check your connection before trying again.'
              : 'Could not check confirmation. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close verification',
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded, size: 21),
                    color: Colors.grey.shade500,
                  ),
                ),
                const Text(
                  'Verify your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Open the confirmation link in the email sent to',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  "Then return here and tap I've confirmed my email.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy || _resendSeconds > 0
                      ? null
                      : () => _submit(resend: true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: Text(
                    _resendSeconds > 0
                        ? 'Resend email in ${_resendSeconds}s'
                        : 'Resend email',
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 4),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _busy ? null : () => _submit(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "I've confirmed my email",
                            style: TextStyle(fontSize: 16),
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
