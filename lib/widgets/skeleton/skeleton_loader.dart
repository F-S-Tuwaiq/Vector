import 'package:flutter/material.dart';

import '../../theme/vector_colors.dart';

/// Wraps any number of [SkeletonBox]es with one shared shimmer sweep.
///
/// A single controller drives the whole subtree so a screen with several
/// skeleton rows/cards only pays for one animation, not one per box.
///
/// IMPORTANT: only wrap the placeholder shapes themselves — never a solid
/// card/page background around them. The shimmer blends with
/// [BlendMode.srcATop], which replaces color per-pixel across its whole
/// child; a background included in that subtree would be overwritten to
/// the same shade as the shapes on top of it, erasing the contrast between
/// them (and collapsing to a flat, shapeless blob when the shimmer is
/// paused for reduced motion).
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                VectorColors.skeletonBase,
                VectorColors.skeletonHighlight,
                VectorColors.skeletonBase,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1 + 3 * t, 0),
              end: Alignment(0 + 3 * t, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single solid placeholder shape — a line, an avatar, a card face.
/// Meant to sit inside a [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  const SkeletonBox.circle({required double size, super.key})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle;

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: VectorColors.skeletonBase,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );
  }
}
