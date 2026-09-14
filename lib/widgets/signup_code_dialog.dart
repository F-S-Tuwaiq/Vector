import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../services/supabase_service.dart';

class SignupCodeDialog extends StatefulWidget {
  const SignupCodeDialog({super.key, required this.email});
  final String email;

  @override
  State<SignupCodeDialog> createState() => _SignupCodeDialogState();
}

class _SignupCodeDialogState extends State<SignupCodeDialog> {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _submit({bool resend = false}) async {
    if (_busy) return;
    if (!resend && !RegExp(r'^\d{6,10}$').hasMatch(_code.text.trim())) {
      setState(() => _message = 'Enter the full code from your email.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (resend) {
        await SupabaseService.resendSignupCode(widget.email);
        if (mounted) setState(() => _message = 'A new code has been sent.');
      } else {
        await SupabaseService.verifySignupCode(widget.email, _code.text);
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = resend
              ? 'Could not resend yet. Wait a minute and try again.'
              : 'Code invalid or expired. Try again or request a new code.',
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
                  'Enter the code sent to',
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
                _digitBoxes(),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : () => _submit(resend: true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: const Text('Resend email'),
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
                        : const Text('Verify', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // One real input preserves paste, autofill, and natural backspace behavior.
  // The visual boxes also accommodate projects configured for longer OTPs.
  Widget _digitBoxes() => ListenableBuilder(
    listenable: Listenable.merge([_code, _codeFocus]),
    builder: (context, _) {
      final digits = _code.text;
      final count = digits.length.clamp(6, 10);
      final active = _code.selection.extentOffset.clamp(0, count - 1);
      return SizedBox(
        height: 56,
        child: Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                label: 'Verification code',
                child: TextField(
                  controller: _code,
                  focusNode: _codeFocus,
                  enabled: !_busy,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  autocorrect: false,
                  enableSuggestions: false,
                  showCursor: false,
                  style: const TextStyle(color: Colors.transparent),
                  cursorColor: Colors.transparent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    counterText: '',
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Row(
                    children: List.generate(count, (index) {
                      final focused = _codeFocus.hasFocus && active == index;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(
                            right: index == count - 1 ? 0 : 6,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F6FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: focused
                                  ? AppColors.purple
                                  : const Color(0xFFE6E0EA),
                              width: focused ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            index < digits.length ? digits[index] : '',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
