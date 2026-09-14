import 'package:flutter/material.dart';

import '../widgets/vector_bottom_bar.dart';
import 'home_screen.dart';
import 'invites_screen.dart';
import 'profile_screen.dart';

/// The app's 3-tab shell. Uses [IndexedStack] so all three tabs stay
/// mounted (and keep their state) across switches; only the fade-in and
/// the bottom-bar triangle animate.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  void _onChanged(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    if (MediaQuery.disableAnimationsOf(context)) {
      _fade.value = 1;
    } else {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: IndexedStack(
          index: _index,
          children: const [HomeScreen(), InvitesScreen(), ProfileScreen()],
        ),
      ),
      bottomNavigationBar: VectorBottomBar(
        index: _index,
        onChanged: _onChanged,
      ),
    );
  }
}
