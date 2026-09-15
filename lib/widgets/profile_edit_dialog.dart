import 'package:flutter/material.dart';

import '../theme/profile_theme.dart';
import '../theme/vector_colors.dart';
import 'profile_widgets.dart';

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.multiline = false,
  });
  final String title;
  final Map<String, String> fields;
  final Future<void> Function(Map<String, String>) onSave;
  final bool multiline;
  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final Map<String, TextEditingController> _controllers;
  @override
  void initState() {
    super.initState();
    _controllers = widget.fields.map(
      (key, value) => MapEntry(
        key,
        TextEditingController.fromValue(
          TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
        ),
      ),
    );
  }

  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_controllers['Name']?.text.trim().isEmpty == true) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    for (final entry in {
      'GitHub': 'github.com',
      'LinkedIn': 'linkedin.com',
    }.entries) {
      final value = _controllers[entry.key]?.text.trim() ?? '';
      if (value.isEmpty) continue;
      final uri = Uri.tryParse(
        value.startsWith('https://') ? value : 'https://$value',
      );
      if (uri == null ||
          !(uri.host == entry.value || uri.host.endsWith('.${entry.value}'))) {
        setState(() => _error = 'Enter a valid ${entry.key} link.');
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        _controllers.map((key, value) => MapEntry(key, value.text.trim())),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save your changes. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      backgroundColor: VectorColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 28, height: 2, color: VectorColors.apricot),
          const SizedBox(height: 14),
          Text(widget.title, style: ProfileTheme.heading),
          const SizedBox(height: 8),
          Text(
            widget.multiline
                ? 'A few words about you and how you like to build.'
                : 'Your name and the places to find your work.',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              height: 1.5,
              color: VectorColors.textSecondary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._controllers.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: entry.value,
                    enabled: !_saving,
                    minLines: widget.multiline ? 3 : 1,
                    maxLines: widget.multiline ? 7 : 1,
                    maxLength: widget.multiline ? 1000 : 200,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      counterText: '',
                    ),
                  ),
                ),
              ),
              if (_error != null) Text(_error!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ProfileAction(
          label: _saving ? 'Saving…' : 'Save',
          onPressed: _saving ? null : _save,
        ),
      ],
    ),
  );
}
