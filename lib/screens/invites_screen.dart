import 'package:flutter/material.dart';

import '../widgets/empty_state_screen.dart';

class InvitesScreen extends StatelessWidget {
  const InvitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateScreen(
      headerTitle: 'Invites',
      icon: Icons.mail_outline_rounded,
      title: 'No invites yet',
      subtitle: 'Team invitations you receive will show up here.',
      showBackButton: false,
    );
  }
}
