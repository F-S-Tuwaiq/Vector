import 'package:flutter/material.dart';

import '../widgets/vector_bottom_bar.dart';
import '../data/profile_repository.dart';
import 'home_screen.dart';
import 'invites_screen.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    this.profileRepository = const ProfileRepository(),
  });
  final ProfileRepository profileRepository;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );
  late final Animation<double> _fadeCurve = CurvedAnimation(
    parent: _fade,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(_fadeCurve);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.015),
    end: Offset.zero,
  ).animate(_fadeCurve);

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<InvitesScreenState> _invitesKey =
      GlobalKey<InvitesScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  void _onChanged(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    if (MediaQuery.disableAnimationsOf(context)) {
      _fade.value = 1;
    } else {
      _fade.forward(from: 0);
    }
    if (i == 1) _invitesKey.currentState?.refreshOnFocus();
    if (i == 2) _profileKey.currentState?.refreshOnFocus();
  }

  void _openHackathonFromInvite(String hackathonId) {
    _onChanged(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeKey.currentState?.openHackathonExpanded(hackathonId);
    });
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
        opacity: _fadeCurve,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            child: IndexedStack(
              index: _index,
              children: [
                TickerMode(
                  enabled: _index == 0,
                  child: HomeScreen(key: _homeKey),
                ),
                TickerMode(
                  enabled: _index == 1,
                  child: InvitesScreen(
                    key: _invitesKey,
                    onOpenHackathon: _openHackathonFromInvite,
                  ),
                ),
                TickerMode(
                  enabled: _index == 2,
                  child: ProfileScreen(
                    key: _profileKey,
                    repository: widget.profileRepository,
                    onBack: () => _onChanged(0),
                    onDiscover: () => _onChanged(0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: VectorBottomBar(
        index: _index,
        onChanged: _onChanged,
      ),
    );
  }
}
