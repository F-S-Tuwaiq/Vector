import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../theme/profile_theme.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/brand_loader/brand_full_screen_loader.dart';
import 'about_us_screen.dart';
import 'log_in_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.profile});
  final Map<String, dynamic> profile;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _signingOut = false;
  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  void _info(String title, String text) => _open(
    ProfileDetailPage(
      title: title,
      children: [ProfileSurface(child: Text(text))],
    ),
  );

  Future<void> _logout() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await runWithBrandFullScreenLoader(context, () async {
        if (SupabaseService.isLoggedIn) await SupabaseService.signOut();
      }, sequence: VLogoSequence.oneV);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => LogInScreen(onSignIn: SupabaseService.signIn),
        ),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _signingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log out. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ProfileTheme.data,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: ProfileTheme.heading),
        backgroundColor: VectorColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _section('ACCOUNT', [
            _row(
              'Personal Information',
              Icons.person_outline,
              () => _open(PersonalInformationScreen(profile: widget.profile)),
            ),
            _row(
              'Change Password',
              Icons.lock_outline,
              () => _open(const ChangePasswordScreen()),
            ),
          ]),
          _section('PREFERENCES', [
            _row(
              'Notifications',
              Icons.notifications_outlined,
              () => _open(const NotificationPreferencesScreen()),
            ),
            _row(
              'Language',
              Icons.language,
              () => _info(
                'Language',
                'English is the current app language. More languages will be available in a future update.',
              ),
            ),
            _row(
              'Appearance',
              Icons.palette_outlined,
              () => _info(
                'Appearance',
                'Vector uses a light theme with lavender surfaces, deep purple details and warm apricot accents. Additional themes are not available yet.',
              ),
            ),
          ]),
          _section('PRIVACY', [
            _row(
              'Privacy Settings',
              Icons.shield_outlined,
              () => _info(
                'Privacy Settings',
                'Your name, skills and certificates are associated with your account. Only add information you are comfortable sharing with potential teammates. Profile visibility controls are not available yet.',
              ),
            ),
          ]),
          _section('SUPPORT', [
            _row(
              'Help & Support',
              Icons.help_outline,
              () => _open(
                const ProfileDetailPage(
                  title: 'Help & Support',
                  children: [
                    Text('How can we help?', style: VectorText.headlineMedium),
                    SizedBox(height: 20),
                    Text(
                      'How do I add a certificate?',
                      style: VectorText.titleMedium,
                    ),
                    Text(
                      'Open Profile, tap the pencil beside Skills & evidence, then tap Attach evidence beside a skill. Choose a PDF, PNG or JPEG. You can attach up to 3 certificates per skill.',
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Where are my signup skills?',
                      style: VectorText.titleMedium,
                    ),
                    Text(
                      'Your profile loads the skills saved during signup. Pull down on the profile to refresh. If loading fails, check your connection and try again.',
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Are these my real teams?',
                      style: VectorText.titleMedium,
                    ),
                    Text(
                      'The two sample teams are labeled in your profile and linked to events on Home. Previous participation is shown only when participation data is available.',
                    ),
                  ],
                ),
              ),
            ),
            _row(
              'About us',
              Icons.info_outline,
              () => _open(const AboutUsScreen()),
            ),
          ]),
          const Divider(),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _signingOut ? null : _logout,
            icon: const Icon(Icons.logout, color: VectorColors.error),
            label: Text(
              _signingOut ? 'Logging out…' : 'Log Out',
              style: const TextStyle(color: VectorColors.error),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _section(String title, List<Widget> rows) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: VectorText.labelSmall.copyWith(
            color: VectorColors.textSecondaryPurple,
          ),
        ),
        const SizedBox(height: 12),
        ProfileSurface(
          accent: title == 'PREFERENCES' || title == 'SUPPORT'
              ? VectorColors.apricot
              : VectorColors.purpleBrand,
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    ),
  );
  Widget _row(String title, IconData icon, VoidCallback onTap) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VectorColors.apricot.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 21, color: VectorColors.purpleBrand),
    ),
    title: Text(title, style: ProfileTheme.data.textTheme.titleMedium),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key, required this.profile});
  final Map<String, dynamic> profile;
  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  late final _name = TextEditingController(
    text:
        (widget.profile['full_name'] ??
                SupabaseService.currentUser?.userMetadata?['full_name'] ??
                '')
            .toString(),
  );
  late final _github = TextEditingController(
    text: widget.profile['github']?.toString() ?? '',
  );
  late final _linkedin = TextEditingController(
    text: widget.profile['linkedin']?.toString() ?? '',
  );
  late final _headline = TextEditingController(
    text:
        (widget.profile['headline'] ??
                SupabaseService.currentUser?.userMetadata?['headline'] ??
                '')
            .toString(),
  );
  late final _about = TextEditingController(
    text:
        (widget.profile['about'] ??
                SupabaseService.currentUser?.userMetadata?['about'] ??
                '')
            .toString(),
  );
  late final _availability = TextEditingController(
    text:
        (widget.profile['availability'] ??
                SupabaseService.currentUser?.userMetadata?['availability'] ??
                '')
            .toString(),
  );
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _headline.dispose();
    _about.dispose();
    _availability.dispose();
    _name.dispose();
    _github.dispose();
    _linkedin.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await SupabaseService.saveProfile(
        fullName: _name.text,
        github: _github.text,
        linkedin: _linkedin.text,
        headline: _headline.text,
        about: _about.text,
        availability: _availability.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save your profile. Please try again.';
        });
      }
    }
  }

  Widget _group(
    String title,
    IconData icon,
    Color accent,
    List<Widget> fields,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: ProfileSurface(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: VectorColors.purpleDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: ProfileTheme.heading.copyWith(fontSize: 25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...fields,
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ProfileDetailPage(
    title: 'Personal Information',
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: VectorColors.purpleDeep,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person_outline,
              color: VectorColors.apricot,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              'Make it yours',
              style: ProfileTheme.heading.copyWith(
                color: VectorColors.background,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A name, a little story, and the work you’re proud to share.',
              style: TextStyle(
                color: VectorColors.background.withValues(alpha: .8),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _group('The essentials', Icons.badge_outlined, VectorColors.apricot, [
        TextField(
          controller: _name,
          enabled: !_saving,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        const SizedBox(height: 18),
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Email'),
          child: Text(SupabaseService.currentUser?.email ?? 'Not signed in'),
        ),
      ]),
      _group('Your work, connected', Icons.link, VectorColors.purpleBrand, [
        TextField(
          controller: _github,
          enabled: !_saving,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'GitHub',
            hintText: 'github.com/username',
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _linkedin,
          enabled: !_saving,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'LinkedIn',
            hintText: 'linkedin.com/in/username',
          ),
        ),
      ]),
      _group('Your introduction', Icons.edit_note, VectorColors.apricot, [
        TextField(
          controller: _headline,
          enabled: !_saving,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Professional headline'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _availability,
          enabled: !_saving,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'Availability',
            hintText: 'Open to joining a team',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _about,
          enabled: !_saving,
          minLines: 3,
          maxLines: 6,
          maxLength: 1000,
          decoration: const InputDecoration(labelText: 'About'),
        ),
      ]),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            _error!,
            style: const TextStyle(color: VectorColors.error),
          ),
        ),
      ProfileAction(
        label: _saving ? 'Saving…' : 'Save changes',
        onPressed: _saving || !SupabaseService.isLoggedIn ? null : _save,
      ),
    ],
  );
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _password = TextEditingController(), _confirm = TextEditingController();
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: _password.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password updated.')));
      Navigator.pop(context);
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not update your password. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => ProfileDetailPage(
    title: 'Change Password',
    children: [
      const Text('Choose a strong password with at least 8 characters.'),
      const SizedBox(height: 24),
      TextField(
        controller: _password,
        obscureText: true,
        enabled: !_saving,
        enableSuggestions: false,
        autocorrect: false,
        decoration: const InputDecoration(labelText: 'New password'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _confirm,
        obscureText: true,
        enabled: !_saving,
        enableSuggestions: false,
        autocorrect: false,
        decoration: const InputDecoration(labelText: 'Confirm new password'),
      ),
      const SizedBox(height: 16),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: VectorColors.error)),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _saving || !SupabaseService.isLoggedIn ? null : _save,
        child: Text(_saving ? 'Updating…' : 'Update password'),
      ),
    ],
  );
}

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});
  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late bool _teams =
      SupabaseService.currentUser?.userMetadata?['notify_teams'] as bool? ??
      true;
  late bool _hackathons =
      SupabaseService.currentUser?.userMetadata?['notify_hackathons']
          as bool? ??
      true;
  bool _saving = false;
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(
          data: {'notify_teams': _teams, 'notify_hackathons': _hackathons},
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Preferences saved.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save preferences. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ProfileDetailPage(
    title: 'Notifications',
    children: [
      const Text(
        'Save your preferences for team and hackathon updates. Notification delivery is not enabled yet.',
      ),
      const SizedBox(height: 20),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Team updates'),
        subtitle: const Text('Invitations and join requests'),
        value: _teams,
        onChanged: _saving ? null : (value) => setState(() => _teams = value),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Hackathon updates'),
        subtitle: const Text('Events and opportunities'),
        value: _hackathons,
        onChanged: _saving
            ? null
            : (value) => setState(() => _hackathons = value),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: _saving || !SupabaseService.isLoggedIn ? null : _save,
        child: Text(_saving ? 'Saving…' : 'Save preferences'),
      ),
    ],
  );
}
