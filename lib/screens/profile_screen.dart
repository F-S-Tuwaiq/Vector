import 'package:flutter/material.dart';

import '../widgets/empty_state_screen.dart';

/// The Profile nav tab (no [name]) and the member-profile placeholder
/// pushed from the member sheet's "View full profile" (with [name]).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final bool isSelf = name == null;
    return EmptyStateScreen(
      headerTitle: isSelf ? 'Profile' : name!,
      icon: Icons.person_outline_rounded,
      title: isSelf ? 'Your profile' : name!,
      subtitle: isSelf
          ? 'Your skills, teams, and hackathon history will live here.'
          : 'Full profile details are coming soon.',
      showBackButton: !isSelf,
    );
  }
}
