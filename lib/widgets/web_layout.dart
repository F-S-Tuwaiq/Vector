import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Enables the simulator's swipe gestures with a mouse in the browser.
class VectorScrollBehavior extends MaterialScrollBehavior {
  const VectorScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}
