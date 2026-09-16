import 'package:flutter/material.dart';

import 'v_logo_animation.dart';

/// Mini version of the brand loader: same 2s draw/hold/fade timing and
/// colors as [BrandFullScreenLoader], scaled to ~72px, no dots, shown over
/// a 35%-black dim rather than a full opaque background.
///
/// Reserved for genuinely heavy operations expected to take more than
/// 2-3 seconds (large file uploads, heavy processing) — never for routine
/// reads (use a skeleton loader) or writes (use an in-button spinner).
class BrandMiniLoaderOverlay extends StatelessWidget {
  const BrandMiniLoaderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: const Center(child: VLogoAnimation(size: 72)),
      ),
    );
  }
}

/// Shows [BrandMiniLoaderOverlay] above the current screen while [task]
/// runs, then removes it and returns the task's result.
Future<T> runWithBrandMiniLoader<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  final overlayState = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(builder: (_) => const BrandMiniLoaderOverlay());
  overlayState.insert(entry);
  try {
    return await task();
  } finally {
    entry.remove();
  }
}
