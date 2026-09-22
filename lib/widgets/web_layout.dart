import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class VectorScrollBehavior extends MaterialScrollBehavior {
  const VectorScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}
