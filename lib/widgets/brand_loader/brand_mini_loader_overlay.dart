import 'package:flutter/material.dart';

import 'v_logo_animation.dart';

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
