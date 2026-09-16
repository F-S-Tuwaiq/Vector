import 'package:flutter/material.dart';

import '../../theme/vector_colors.dart';
import 'brand_loading_dots.dart';
import 'v_logo_animation.dart';

/// Full-screen brand loading moment: the app's main purple background,
/// centered self-drawing "V" mark, blinking dots below.
///
/// Reserved for exactly three moments app-wide: app launch (while checking
/// auth state), right after login/sign-up submission (while the server
/// responds), and it is NOT used for routine data reads or writes — see
/// [BrandMiniLoaderOverlay] for heavy one-off operations, skeleton loaders
/// for reads, and in-button spinners for writes.
class BrandFullScreenLoader extends StatelessWidget {
  const BrandFullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VectorColors.purpleBrand,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double logoSize = (constraints.maxWidth * 0.52).clamp(
            0,
            260,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VLogoAnimation(size: logoSize),
              const SizedBox(height: 28),
              const BrandLoadingDots(),
            ],
          );
        },
      ),
    );
  }
}

/// Shows [BrandFullScreenLoader] full-screen above everything (including
/// any app bar / scaffold chrome) while [task] runs, then removes it and
/// returns the task's result. Use for login/sign-up submission and app
/// launch — never for a routine data read or write.
Future<T> runWithBrandFullScreenLoader<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  final overlayState = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(builder: (_) => const BrandFullScreenLoader());
  overlayState.insert(entry);
  try {
    return await task();
  } finally {
    entry.remove();
  }
}
