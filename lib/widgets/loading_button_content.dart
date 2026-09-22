import 'package:flutter/material.dart';

class LoadingButtonContent extends StatelessWidget {
  const LoadingButtonContent({
    required this.loading,
    required this.child,
    this.spinnerColor,
    this.spinnerSize = 18,
    super.key,
  });

  final bool loading;
  final Widget child;
  final Color? spinnerColor;
  final double spinnerSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: spinnerSize,
              height: spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: spinnerColor,
              ),
            )
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}
