import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'v_logo_animation.dart';
export 'v_logo_animation.dart' show VLogoSequence;

/// Blurs the current page while keeping the animated V sharp above it.
class BrandFullScreenLoader extends StatelessWidget {
  const BrandFullScreenLoader({super.key, this.sequence, this.onComplete});

  final VLogoSequence? sequence;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: 0.22),
              ),
              Center(
                child: Semantics(
                  label: 'Loading',
                  liveRegion: true,
                  child: VLogoAnimation(
                    size: 120,
                    sequence: sequence,
                    onComplete: onComplete,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the page mounted and visible beneath its loading overlay.
class BrandLoadingRegion extends StatelessWidget {
  const BrandLoadingRegion({
    super.key,
    required this.loading,
    required this.child,
  });

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [child, if (loading) const BrandFullScreenLoader()],
  );
}

/// Shows [BrandFullScreenLoader] full-screen above everything (including
/// any app bar / scaffold chrome) while [task] runs, then removes it and
/// returns the task's result. Also used when fetching data before navigation.
Future<T> runWithBrandFullScreenLoader<T>(
  BuildContext context,
  Future<T> Function() task, {
  VLogoSequence? sequence,
}) async {
  final overlayState = Overlay.of(context, rootOverlay: true);
  final animationDone = Completer<void>();
  if (sequence == null) animationDone.complete();
  final entry = OverlayEntry(
    builder: (_) => BrandFullScreenLoader(
      sequence: sequence,
      onComplete: () {
        if (!animationDone.isCompleted) animationDone.complete();
      },
    ),
  );
  overlayState.insert(entry);
  try {
    return await task();
  } finally {
    await animationDone.future;
    entry.remove();
    entry.dispose();
  }
}
