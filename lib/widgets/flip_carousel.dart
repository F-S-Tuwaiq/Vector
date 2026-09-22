import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlipCarousel extends StatefulWidget {
  const FlipCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onPageChanged,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ValueChanged<int>? onPageChanged;

  @override
  State<FlipCarousel> createState() => _FlipCarouselState();
}

class _FlipCarouselState extends State<FlipCarousel> {
  late final PageController _controller = PageController(viewportFraction: 1.0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return PageView.builder(
        controller: _controller,
        itemCount: widget.itemCount,
        onPageChanged: (i) => widget.onPageChanged?.call(i),
        itemBuilder: widget.itemBuilder,
      );
    }

    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      onPageChanged: (i) => widget.onPageChanged?.call(i),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double page;
            if (_controller.position.haveDimensions) {
              page = _controller.page ?? index.toDouble();
            } else {
              page = index.toDouble();
            }
            final delta = (index - page).clamp(-1.0, 1.0);
            final scale = 1 - delta.abs() * 0.1;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(delta * math.pi * 0.75)
                ..scaleByDouble(scale, scale, scale, 1),
              child: Opacity(opacity: 1 - delta.abs() * 0.6, child: child),
            );
          },
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}
