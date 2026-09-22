import 'package:flutter/material.dart';

import '../data/hackathon_repository.dart';
import '../models/hackathon.dart';
import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/vector_header.dart';

const List<String> _kSuggestedRoles = [
  'UI/UX Designer',
  'Backend Developer',
  'Flutter Developer',
  'Data Analyst',
  'Marketer',
];

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key, required this.hackathon});

  final Hackathon hackathon;

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _repo = HackathonRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _customRoleController = TextEditingController();
  final _customRoleFocus = FocusNode();

  int _size = 5;
  final Set<String> _selectedRoles = {};
  bool _addingCustomRole = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _customRoleController.dispose();
    _customRoleFocus.dispose();
    super.dispose();
  }

  void _toggleRole(String role) {
    setState(() {
      if (!_selectedRoles.remove(role)) _selectedRoles.add(role);
    });
  }

  void _commitCustomRole() {
    final text = _customRoleController.text.trim();
    setState(() {
      if (text.isNotEmpty) _selectedRoles.add(text);
      _customRoleController.clear();
      _addingCustomRole = false;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one role you need.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final Team? created = await _repo.createTeam(
      hackathonId: widget.hackathon.id,
      name: _nameController.text.trim(),
      maxMembers: _size,
      missingRoles: _selectedRoles.toList(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (created != null) {
      Navigator.of(context).pop(created);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't create the team. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VectorColors.background,
      body: Column(
        children: [
          const VectorHeader.slim(title: 'Create your team'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TEAM NAME', style: _label),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _nameController,
                      hint: 'e.g. Night Owls',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Team name is required'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    Text('TEAM SIZE', style: _label),
                    const SizedBox(height: 8),
                    _SizeSelector(
                      value: _size,
                      onChanged: (v) => setState(() => _size = v),
                    ),
                    const SizedBox(height: 22),
                    Text('ROLES YOU NEED', style: _label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final role in _kSuggestedRoles)
                          _RoleChip(
                            label: role,
                            selected: _selectedRoles.contains(role),
                            onTap: () => _toggleRole(role),
                          ),
                        for (final role in _selectedRoles.where(
                          (r) => !_kSuggestedRoles.contains(r),
                        ))
                          _RoleChip(
                            label: role,
                            selected: true,
                            onTap: () => _toggleRole(role),
                          ),
                        if (_addingCustomRole)
                          _CustomRoleField(
                            controller: _customRoleController,
                            focusNode: _customRoleFocus,
                            onSubmit: _commitCustomRole,
                          )
                        else
                          _AddCustomRoleChip(
                            onTap: () {
                              setState(() => _addingCustomRole = true);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _customRoleFocus.requestFocus();
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text('ABOUT YOUR TEAM (OPTIONAL)', style: _label),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _aboutController,
                      hint:
                          'One line about your vibe and what '
                          "you're building…",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                VectorColors.buttonStart,
                                VectorColors.buttonEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: _submitting ? null : _submit,
                            child: Center(
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: VectorColors.textNeutral,
                                      ),
                                    )
                                  : Text(
                                      'Create team',
                                      style: VectorText.labelLarge.copyWith(
                                        color: VectorColors.textNeutral,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You'll be the team lead · invites come next",
                      textAlign: TextAlign.center,
                      style: VectorText.labelMedium.copyWith(
                        color: VectorColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final TextStyle _label = VectorText.labelSmall.copyWith(
  color: VectorColors.textSecondaryPurple,
);

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: VectorText.bodyLarge.copyWith(color: VectorColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: VectorText.bodyLarge.copyWith(color: VectorColors.textMuted),
        filled: true,
        fillColor: VectorColors.surfaceWhite,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 14 : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: VectorColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: VectorColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: VectorColors.inputFocus,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: VectorColors.error),
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final size in [3, 4, 5])
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: size == 5 ? 0 : 10),
              child: _SizeSegment(
                size: size,
                selected: size == value,
                onTap: () => onChanged(size),
              ),
            ),
          ),
      ],
    );
  }
}

class _SizeSegment extends StatelessWidget {
  const _SizeSegment({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final int size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? VectorColors.apricot : VectorColors.surfaceWhite,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? VectorColors.apricot : VectorColors.inputBorder,
          ),
        ),
        child: Text(
          '$size',
          style: VectorText.labelLarge.copyWith(
            color: selected
                ? VectorColors.textNeutral
                : VectorColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 8),
        decoration: ShapeDecoration(
          color: selected ? VectorColors.apricot : VectorColors.surfaceLavender,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: VectorText.labelMedium.copyWith(
                color: selected
                    ? VectorColors.textNeutral
                    : VectorColors.textSecondaryPurple,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close_rounded,
                size: 15,
                color: VectorColors.textNeutral,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddCustomRoleChip extends StatelessWidget {
  const _AddCustomRoleChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: StadiumBorder(
            side: const BorderSide(color: VectorColors.inputBorder, width: 1.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 15,
              color: VectorColors.textSecondaryPurple,
            ),
            const SizedBox(width: 4),
            Text(
              'Add your own',
              style: VectorText.labelMedium.copyWith(
                color: VectorColors.textSecondaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomRoleField extends StatelessWidget {
  const _CustomRoleField({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 36,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: VectorText.labelMedium.copyWith(color: VectorColors.textPrimary),
        onSubmitted: (_) => onSubmit(),
        onEditingComplete: onSubmit,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Type a role…',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          filled: true,
          fillColor: VectorColors.surfaceLavender,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
