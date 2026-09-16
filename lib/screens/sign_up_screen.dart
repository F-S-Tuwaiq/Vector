import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

import '../data/skill_catalog.dart';
import 'root_shell.dart';
import '../constants/app_constants.dart';
import '../legal/vector_legal.dart';
import '../services/supabase_service.dart';
import '../widgets/brand_loader/brand_full_screen_loader.dart';
import '../widgets/signup_code_dialog.dart';
import '../widgets/vector_shapes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onCreateAccount});

  final Future<void> Function({
    required String fullName,
    required String email,
    required String password,
    String? github,
    String? linkedin,
    required List<String> skills,
    required Map<String, List<XFile>> certificates,
  })?
  onCreateAccount;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  final TextEditingController _name = TextEditingController();

  final TextEditingController _email = TextEditingController();

  final TextEditingController _password = TextEditingController();

  final TextEditingController _github = TextEditingController();

  final TextEditingController _linkedin = TextEditingController();
  final Map<String, List<XFile>> _skillCertificates = {};

  late final AnimationController _floating;
  late final AnimationController _entrance;
  late final Animation<double> _fade;

  bool _started = false;
  bool _obscure = true;
  bool _loading = false;
  bool _awaitingVerification = false;

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _agreedToLegal = false;

  String _category = 'Design';

  final List<String> _selectedSkills = [
    'UI / UX design',
    'Figma',
    'User research',
    'HTML / CSS',
  ];

  final _skills = skillCatalog;

  @override
  void initState() {
    super.initState();

    _floating = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);

    _name.addListener(_refresh);
    _email.addListener(_refresh);
    _password.addListener(_refresh);
    _github.addListener(_refresh);
    _linkedin.addListener(_refresh);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickCertificateForSkill(String skill) async {
    try {
      const pdfGroup = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        uniformTypeIdentifiers: ['com.adobe.pdf'],
      );

      const imageGroup = XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png'],
        uniformTypeIdentifiers: ['public.jpeg', 'public.png'],
      );

      final files = await openFiles(
        acceptedTypeGroups: [pdfGroup, imageGroup],
        confirmButtonText: 'Attach',
      );

      if (files.isEmpty) {
        return;
      }

      final currentFiles = _skillCertificates[skill] ?? <XFile>[];

      const maxFilesPerSkill = 3;

      final remaining = maxFilesPerSkill - currentFiles.length;

      if (remaining <= 0) {
        _showMessage('You can attach up to 3 certificates to each skill.');
        return;
      }

      final filesToAdd = files.take(remaining).toList();

      setState(() {
        _skillCertificates[skill] = [...currentFiles, ...filesToAdd];
      });

      if (files.length > remaining) {
        _showMessage('You can attach up to 3 certificates to each skill.');
      }
    } catch (e) {
      debugPrint('Certificate picker error: $e');

      _showMessage('Could not open certificate picker.');
    }
  }

  void _removeCertificateFromSkill(String skill, XFile file) {
    final files = _skillCertificates[skill];

    if (files == null) {
      return;
    }

    setState(() {
      files.remove(file);

      if (files.isEmpty) {
        _skillCertificates.remove(skill);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      _entrance.value = 1;
      _floating.stop();
      _started = true;
    } else {
      if (!_started) {
        _started = true;
        _entrance.forward();
      }

      if (!_floating.isAnimating) {
        _floating.repeat();
      }
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();

    _floating.dispose();
    _entrance.dispose();

    _name.dispose();
    _email.dispose();
    _password.dispose();
    _github.dispose();
    _linkedin.dispose();

    super.dispose();
  }

  bool get _validEmail {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
  }

  bool get _validPassword {
    return _password.text.length >= 8;
  }

  bool get _legalAccepted {
    return _agreedToLegal;
  }

  bool get _canContinue {
    return _name.text.trim().isNotEmpty &&
        _validEmail &&
        _validPassword &&
        _legalAccepted;
  }

  double get _accountProgress {
    int completed = 0;

    if (_name.text.trim().isNotEmpty) {
      completed++;
    }

    if (_validEmail) {
      completed++;
    }

    if (_validPassword) {
      completed++;
    }

    if (_legalAccepted) {
      completed++;
    }

    return completed / 4;
  }

  double get _skillsProgress {
    return (_selectedSkills.length / 6).clamp(0.0, 1.0).toDouble();
  }

  String get _passwordLabel {
    if (_password.text.isEmpty) {
      return '';
    }

    if (_password.text.length < 5) {
      return 'Weak';
    }

    if (_password.text.length < 8) {
      return 'Fair';
    }

    return 'Good';
  }

  Future<void> _nextStep() async {
    FocusScope.of(context).unfocus();

    if (_name.text.trim().isEmpty) {
      _showMessage('Enter your full name.');
      return;
    }

    if (!_validEmail) {
      _showMessage('Enter a valid email address.');
      return;
    }

    if (!_validPassword) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }

    if (!_agreedToLegal) {
      _showMessage(
        'You must agree to the Terms of Use and Privacy Policy before continuing.',
      );
      return;
    }

    await _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _previousStep() async {
    FocusScope.of(context).unfocus();

    await _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _createAccount() async {
    if (_selectedSkills.length < 3) {
      _showMessage('Choose at least 3 skills.');

      return;
    }

    if (_loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      if (widget.onCreateAccount != null) {
        await runWithBrandFullScreenLoader(
          context,
          () => widget.onCreateAccount!(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            github: _github.text.trim().isEmpty ? null : _github.text.trim(),
            linkedin: _linkedin.text.trim().isEmpty
                ? null
                : _linkedin.text.trim(),
            skills: List<String>.from(_selectedSkills),
            certificates: Map<String, List<XFile>>.from(_skillCertificates),
          ),
          sequence: VLogoSequence.oneVAndWhite,
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RootShell()),
          (route) => false,
        );
      } else {
        if (!mounted) {
          return;
        }

        _showMessage('Connect your authentication backend to onCreateAccount.');
      }
    } on EmailVerificationRequired {
      if (!mounted) return;
      setState(() => _awaitingVerification = true);
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => SignupCodeDialog(email: _email.text.trim(), password: _password.text),
      );
      if (verified == true && mounted) {
        setState(() => _loading = false);
        await _createAccount();
      }
    } catch (e, stackTrace) {
      debugPrint('CREATE ACCOUNT ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openTerms() async {
    final accepted = await showVectorLegalDocument(
      context,
      VectorLegalDocument.terms,
    );

    if (!mounted) {
      return;
    }

    if (accepted) {
      setState(() {
        _acceptedTerms = true;
      });
    }
  }

  Future<void> _openPrivacy() async {
    final accepted = await showVectorLegalDocument(
      context,
      VectorLegalDocument.privacy,
    );

    if (!mounted) {
      return;
    }

    if (accepted) {
      setState(() {
        _acceptedPrivacy = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 460.0);

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  height: constraints.maxHeight,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [_accountPage(), _skillsPage()],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _accountPage() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.zero,
      children: [
        _signUpHeader(),

        Padding(
          padding: const EdgeInsets.fromLTRB(30, 13, 30, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP 1 OF 2  ·  ACCOUNT',
                style: AppTypography.sans(
                  size: 10.5,
                  color: AppColors.mutedDeep,
                  weight: FontWeight.w600,
                  spacing: 3,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your next chapter.',
                style: AppTypography.display(size: 40, height: 1),
              ),

              const SizedBox(height: 5),

              Text(
                'Start with the essentials.',
                style: AppTypography.sans(size: 18, color: AppColors.muted),
              ),

              const SizedBox(height: 20),

              _progressBar(_accountProgress),

              const SizedBox(height: 24),

              _vectorField(
                controller: _name,
                label: 'FULL NAME',
                hint: 'Salem Alotaibi',
                action: TextInputAction.next,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 12),

              _vectorField(
                controller: _email,
                label: 'EMAIL ADDRESS',
                hint: 'salem@example.com',
                action: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              _vectorField(
                controller: _password,
                label: 'PASSWORD',
                hint: '••••••••',
                action: TextInputAction.done,
                password: true,
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your profiles',
                      style: AppTypography.display(size: 29, height: 1),
                    ),
                  ),
                  Text(
                    'Optional',
                    style: AppTypography.sans(size: 12, color: AppColors.muted),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                'Link your work to enrich your profile.',
                style: AppTypography.sans(size: 13, color: AppColors.muted),
              ),

              const SizedBox(height: 15),

              _profileField(
                controller: _github,
                title: 'GitHub',
                hint: 'github.com/username',
                icon: Icons.code_rounded,
              ),

              const SizedBox(height: 10),

              _profileField(
                controller: _linkedin,
                title: 'LinkedIn',
                hint: 'linkedin.com/in/username',
                icon: Icons.work_outline_rounded,
              ),

              const SizedBox(height: 23),

              _legalAgreement(),

              const SizedBox(height: 24),

              _gradientButton(
                text: 'Continue to skills',
                onTap: _loading ? null : _nextStep,
              ),

              const SizedBox(height: 20),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.sans(
                        size: 14,
                        color: AppColors.muted,
                      ),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.maybePop(context);
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(76, 48),
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      child: Text(
                        'Sign in',
                        style: AppTypography.sans(
                          size: 14,
                          color: AppColors.secondary,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skillsPage() {
    final currentSkills = _skills[_category] ?? const <String>[];

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.zero,
      children: [
        _signUpHeader(showBackButton: true),

        Padding(
          padding: const EdgeInsets.fromLTRB(30, 13, 30, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP 2 OF 2  ·  SKILLS',
                style: AppTypography.sans(
                  size: 10.5,
                  color: AppColors.mutedDeep,
                  weight: FontWeight.w600,
                  spacing: 3,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Show what you bring.',
                style: AppTypography.display(size: 39, height: 1),
              ),

              const SizedBox(height: 6),

              Text(
                'Choose 3–6 skills. Add evidence to support them.',
                style: AppTypography.sans(size: 16, color: AppColors.muted),
              ),

              const SizedBox(height: 20),

              _progressBar(_skillsProgress),

              const SizedBox(height: 23),

              // CATEGORY TABS
              SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _skills.keys.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = _skills.keys.elementAt(index);

                    final selected = _category == category;

                    return ChoiceChip(
                      selected: selected,
                      showCheckmark: false,
                      label: Text(category),
                      onSelected: (_) {
                        setState(() {
                          _category = category;
                        });
                      },
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      selectedColor: AppColors.purpleMid,
                      side: BorderSide(
                        color: selected
                            ? AppColors.purpleMid
                            : AppColors.fieldBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      labelStyle: AppTypography.sans(
                        size: 13,
                        color: selected
                            ? AppColors.background
                            : AppColors.mutedDeep,
                        weight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your skills',
                      style: AppTypography.display(size: 29, height: 1),
                    ),
                  ),
                  Text(
                    '${_selectedSkills.length} of 6',
                    style: AppTypography.sans(size: 12, color: AppColors.muted),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ..._selectedSkills.map((skill) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _selectedSkillCard(skill),
                );
              }),

              // ADD CUSTOM SKILL
              _addSkillCard(currentSkills),

              const SizedBox(height: 23),

              // SUGGESTIONS
              Text(
                'Suggestions',
                style: AppTypography.sans(
                  size: 13,
                  color: AppColors.mutedDeep,
                  weight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentSkills
                    .where((skill) => !_selectedSkills.contains(skill))
                    .take(4)
                    .map((skill) {
                      return ActionChip(
                        avatar: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.mutedDeep,
                        ),
                        label: Text(skill),
                        onPressed: () {
                          _addSkill(skill);
                        },
                        side: const BorderSide(color: AppColors.fieldBorder),
                        backgroundColor: Colors.transparent,
                        labelStyle: AppTypography.sans(
                          size: 12,
                          color: AppColors.mutedDeep,
                          weight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      );
                    })
                    .toList(),
              ),

              const SizedBox(height: 22),

              Text(
                'Certificates are optional. Attach them directly to the skill they support.',
                style: AppTypography.sans(size: 11.5, color: AppColors.muted),
              ),

              const SizedBox(height: 20),

              // CREATE ACCOUNT
              // No in-button spinner here: the full-screen brand loader
              // (via runWithBrandFullScreenLoader above) takes over the
              // instant this is tapped, so there's nothing left for the
              // button itself to show mid-submission.
              _gradientButton(
                text: _awaitingVerification ? 'Complete sign-up' : 'Create account',
                onTap: _loading ? null : _createAccount,
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: _loading ? null : _previousStep,
                  child: Text(
                    'Back to account details',
                    style: AppTypography.sans(size: 12, color: AppColors.muted),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _signUpHeader({bool showBackButton = false}) {
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: VectorSignUpHeaderPainter(animation: _floating),
              ),
            ),
          ),

          if (showBackButton)
            Positioned(
              left: 20,
              top: 38,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _previousStep,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),

          Positioned(
            left: showBackButton ? 65 : 34,
            top: 44,
            child: _wordmark(),
          ),
        ],
      ),
    );
  }

  Widget _wordmark() {
    return Semantics(
      label: 'Vector',
      image: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 29,
              height: 31,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  minWidth: 52,
                  maxWidth: 52,
                  minHeight: 52,
                  maxHeight: 52,
                  child: Image.asset(
                    'assets/logo/vector-mark-dark-1024-removebg-preview.png',
                    width: 52,
                    height: 52,
                  ),
                ),
              ),
            ),

            Text(
              'ector',
              style: AppTypography.sans(
                size: 31,
                color: AppColors.background,
                weight: FontWeight.w500,
                spacing: -1.4,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(double value) {
    final progress = value.clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(99),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          widthFactor: progress,
          heightFactor: 1,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.apricotButtonStart,
                  AppColors.apricotButtonEnd,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _vectorField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputAction action,
    TextInputType? keyboardType,
    bool password = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder, width: 0.8),
      ),
      padding: const EdgeInsets.fromLTRB(13, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.sans(
              size: 9.8,
              color: AppColors.mutedDeep,
              weight: FontWeight.w600,
              spacing: 2,
            ),
          ),

          const SizedBox(height: 1),

          TextField(
            controller: controller,
            enabled: !_loading,
            obscureText: password && _obscure,
            obscuringCharacter: '•',
            keyboardType: keyboardType,
            textInputAction: action,
            autocorrect: false,
            enableSuggestions: !password,
            cursorColor: AppColors.purple,
            style: AppTypography.sans(
              size: 14,
              color: AppColors.purple,
              spacing: password && _obscure ? 2 : -0.15,
            ),
            onSubmitted: (_) {
              if (password) {
                FocusScope.of(context).unfocus();
              }
            },
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              hintText: hint,
              hintStyle: AppTypography.sans(
                size: 14,
                color: AppColors.muted.withValues(alpha: 0.65),
                spacing: password ? 2 : -0.15,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 34,
              ),
              suffixIcon: password
                  ? IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      visualDensity: VisualDensity.compact,
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.mutedDeep,
                      ),
                    )
                  : null,
            ),
          ),

          if (password) ...[
            const SizedBox(height: 3),

            Row(
              children: [
                _passwordStrengthPiece(active: _password.text.isNotEmpty),

                const SizedBox(width: 5),

                _passwordStrengthPiece(active: _password.text.length >= 5),

                const SizedBox(width: 5),

                _passwordStrengthPiece(active: _password.text.length >= 8),

                const SizedBox(width: 10),

                Text(
                  _passwordLabel,
                  style: AppTypography.sans(size: 11, color: AppColors.muted),
                ),
              ],
            ),

            const SizedBox(height: 2),
          ],
        ],
      ),
    );
  }

  Widget _passwordStrengthPiece({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 31,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppColors.apricot : AppColors.lavender,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _profileField({
    required TextEditingController controller,
    required String title,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 61),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder, width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),

          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColors.mutedDeep, size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: TextField(
              controller: controller,
              enabled: !_loading,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              cursorColor: AppColors.purple,
              style: AppTypography.sans(size: 13.5, color: AppColors.purple),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                labelText: title,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: AppTypography.sans(
                  size: 10,
                  color: AppColors.purple,
                  weight: FontWeight.w600,
                  spacing: 1.4,
                ),
                hintText: hint,
                hintStyle: AppTypography.sans(
                  size: 13,
                  color: AppColors.muted.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _legalAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Actual checkbox.
        InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            setState(() {
              _agreedToLegal = !_agreedToLegal;
            });
          },
          child: Container(
            width: 23,
            height: 23,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _agreedToLegal ? AppColors.purple : AppColors.mutedDeep,
                width: 1.1,
              ),
              color: _agreedToLegal ? AppColors.purple : Colors.transparent,
            ),
            child: _agreedToLegal
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.background,
                  )
                : null,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'I agree to the ',
                  style: AppTypography.sans(
                    size: 12.5,
                    color: AppColors.mutedDeep,
                  ),
                ),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openTerms,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      'Terms of Use',
                      style: AppTypography.sans(
                        size: 12.5,
                        color: AppColors.secondary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Text(
                  ' and ',
                  style: AppTypography.sans(
                    size: 12.5,
                    color: AppColors.mutedDeep,
                  ),
                ),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openPrivacy,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      'Privacy Policy.',
                      style: AppTypography.sans(
                        size: 12.5,
                        color: AppColors.secondary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectedSkillCard(String skill) {
    final certificates = _skillCertificates[skill] ?? <XFile>[];

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fieldBorder, width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  size: 20,
                  color: AppColors.purple,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill,
                      style: AppTypography.sans(
                        size: 14,
                        color: AppColors.purpleDeep,
                        weight: FontWeight.w600,
                      ),
                    ),

                    if (certificates.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${certificates.length} certificate${certificates.length == 1 ? '' : 's'} attached',
                        style: AppTypography.sans(
                          size: 10.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Certificate attachment icon
              IconButton(
                tooltip: 'Attach certificate',
                visualDensity: VisualDensity.compact,
                onPressed: _loading
                    ? null
                    : () {
                        _pickCertificateForSkill(skill);
                      },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.workspace_premium_outlined,
                      size: 23,
                      color: AppColors.mutedDeep,
                    ),

                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.apricot,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 9,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Remove $skill',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    _selectedSkills.remove(skill);
                    _skillCertificates.remove(skill);
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                  color: AppColors.mutedDeep,
                ),
              ),
            ],
          ),

          if (certificates.isNotEmpty) ...[
            const SizedBox(height: 10),

            const Divider(height: 1, color: AppColors.fieldBorder),

            const SizedBox(height: 9),

            ...certificates.map(
              (file) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _skillCertificateFile(skill, file),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _skillCertificateFile(String skill, XFile file) {
    final name = file.name;

    final lowerName = name.toLowerCase();

    final isPdf = lowerName.endsWith('.pdf');

    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snapshot) {
        final size = snapshot.data;

        return Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              size: 18,
              color: AppColors.mutedDeep,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      size: 11.5,
                      color: AppColors.purple,
                      weight: FontWeight.w500,
                    ),
                  ),

                  if (size != null)
                    Text(
                      _formatFileSize(size),
                      style: AppTypography.sans(
                        size: 9.5,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Remove certificate',
              visualDensity: VisualDensity.compact,
              onPressed: _loading
                  ? null
                  : () {
                      _removeCertificateFromSkill(skill, file);
                    },
              icon: const Icon(
                Icons.close_rounded,
                size: 17,
                color: AppColors.muted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _addSkillCard(List<String> availableSkills) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        _showAddSkillSheet(availableSkills);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.fieldBorder, width: 0.9),
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: AppColors.lavender.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.purple),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add another skill',
                    style: AppTypography.sans(
                      size: 14,
                      color: AppColors.purple,
                      weight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Can’t find it? Add your own.',
                    style: AppTypography.sans(
                      size: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSkill(String skill) {
    final cleanSkill = skill.trim();

    if (cleanSkill.isEmpty) {
      return;
    }

    final alreadyExists = _selectedSkills.any(
      (existing) => existing.toLowerCase() == cleanSkill.toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    if (_selectedSkills.length >= 6) {
      _showMessage('You can choose up to 6 skills.');

      return;
    }

    setState(() {
      _selectedSkills.add(cleanSkill);
    });
  }

  Future<void> _showAddSkillSheet(List<String> suggestions) async {
    String customSkill = '';

    final selectedSkill = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundBright,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.fieldBorder,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Add a skill',
                      style: AppTypography.display(size: 29, height: 1),
                    ),

                    const SizedBox(height: 17),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions
                          .where((skill) => !_selectedSkills.contains(skill))
                          .map((skill) {
                            return ActionChip(
                              label: Text(skill),
                              onPressed: () {
                                Navigator.of(sheetContext).pop(skill);
                              },
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(
                                color: AppColors.fieldBorder,
                              ),
                              labelStyle: AppTypography.sans(
                                size: 12,
                                color: AppColors.mutedDeep,
                              ),
                            );
                          })
                          .toList(),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      autofocus: false,
                      cursorColor: AppColors.purple,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        customSkill = value;
                      },
                      onSubmitted: (value) {
                        final cleanValue = value.trim();

                        if (cleanValue.isEmpty) {
                          return;
                        }

                        Navigator.of(sheetContext).pop(cleanValue);
                      },
                      style: AppTypography.sans(
                        size: 14,
                        color: AppColors.purple,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a custom skill',
                        hintStyle: AppTypography.sans(
                          size: 14,
                          color: AppColors.muted,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.fieldBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.fieldBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.fieldFocused,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    _gradientButton(
                      text: 'Add skill',
                      onTap: () {
                        final cleanValue = customSkill.trim();

                        if (cleanValue.isEmpty) {
                          return;
                        }

                        Navigator.of(sheetContext).pop(cleanValue);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // The bottom sheet is now finished closing before
    // we modify the signup page state.
    if (!mounted || selectedSkill == null) {
      return;
    }

    _addSkill(selectedSkill);
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return Opacity(
      opacity: onTap == null ? 0.65 : 1,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [AppColors.apricotButtonStart, AppColors.apricotButtonEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.09),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: AppColors.purple,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          style: AppTypography.sans(
                            size: 15,
                            color: AppColors.purple,
                            weight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const SizedBox(
                          width: 12,
                          height: 14,
                          child: CustomPaint(painter: ButtonTrianglePainter()),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
