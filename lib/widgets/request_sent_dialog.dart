import 'package:flutter/material.dart';

import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

/// Shows the "request sent" confirmation dialog for [team].
///
/// Entrance is fade + scale (0.92 -> 1.0) over 300ms, unless
/// [MediaQuery.disableAnimationsOf] is true, in which case the dialog
/// appears instantly at its final state.
Future<void> showRequestSentDialog(BuildContext context, Team team) {
  final disableAnimations = MediaQuery.disableAnimationsOf(context);
  final duration = disableAnimations
      ? Duration.zero
      : const Duration(milliseconds: 300);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Request sent',
    barrierColor: VectorColors.dialogBarrier,
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _RequestSentDialogContent(team: team);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _RequestSentDialogContent extends StatelessWidget {
  const _RequestSentDialogContent({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          color: VectorColors.surfaceWhite,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: VectorColors.hairline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: VectorColors.apricot,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check,
                color: VectorColors.textNeutral,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Request sent',
              style: VectorText.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Your request to join ${team.name} has been sent.\nWaiting for the team's response.",
              style: VectorText.bodyMedium.copyWith(
                color: VectorColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VectorColors.purpleBrand,
                  foregroundColor: VectorColors.textOnPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  'Done',
                  style: VectorText.labelLarge.copyWith(
                    color: VectorColors.textOnPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
