import 'package:flutter/material.dart';

import '../theme/profile_theme.dart';
import '../theme/vector_colors.dart';
import '../widgets/login_style_header.dart';
import '../widgets/profile_widgets.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) => Theme(
    data: ProfileTheme.data,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('About us', style: ProfileTheme.heading),
        backgroundColor: VectorColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                40 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: VectorColors.purpleDeep,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LoginWordmark(),
                        const SizedBox(height: 28),
                        Text(
                          'Different strengths.\nOne shared direction.',
                          style: ProfileTheme.heading.copyWith(
                            fontSize: 35,
                            color: VectorColors.background,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'A meeting at a bootcamp. An idea about belonging. A place to find the people you’ll build with.',
                          style: TextStyle(
                            color: VectorColors.background.withValues(
                              alpha: .8,
                            ),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: CustomPaint(painter: _VectorPaths()),
                        ),
                      ],
                    ),
                  ),
                  const ProfileSection(
                    title: 'It started with two students',
                    child: ProfileSurface(
                      child: Text(
                        'We’re Sham and Fatimah. We met at the Tuwaiq Flutter and Dart bootcamp—two students from different universities, bringing computer science and information technology into the same conversation.\n\nVector grew from a simple idea: having the ambition to build is only the beginning. Finding people whose skills complement yours can give that ambition a direction.',
                      ),
                    ),
                  ),
                  const ProfileSection(
                    title: 'The people behind Vector',
                    child: Column(
                      children: [
                        _FounderCard(
                          initial: 'S',
                          name: 'Sham',
                          subject: 'Computer Science',
                          university: 'Imam Mohammed Ibn Saud University',
                          accent: VectorColors.apricot,
                        ),
                        SizedBox(height: 12),
                        _FounderCard(
                          initial: 'F',
                          name: 'Fatimah',
                          subject: 'Information Technology',
                          university: 'King Saud University',
                          accent: VectorColors.purpleBrand,
                        ),
                      ],
                    ),
                  ),
                  const ProfileSection(
                    title: 'Why “Vector”?',
                    child: ProfileSurface(
                      accent: VectorColors.purpleBrand,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strength, with direction.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'In mathematics, a vector has both magnitude and direction. We liked that an idea could hold both: what you bring, and where you want to go.\n\nA team works in a similar way. Each person contributes a different strength. When those strengths point toward a shared purpose, you can go further together. That’s the spirit behind our name.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ProfileSection(
                    title: 'Built for the next “let’s do it”',
                    child: ProfileSurface(
                      child: Text(
                        'Vector brings hackathon discovery, skills and team connections into one place. Show what you know, support it with your work, and discover people who can help turn an idea into something real.\n\nOur hope is simple: make it easier to move from “I’d love to join” to “we’re building this together.”',
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'From a shared classroom to a shared direction.\nWith care, Sham & Fatimah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.8,
                      color: VectorColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SaudiMadeSignature(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _FounderCard extends StatelessWidget {
  const _FounderCard({
    required this.initial,
    required this.name,
    required this.subject,
    required this.university,
    required this.accent,
  });
  final String initial, name, subject, university;
  final Color accent;
  @override
  Widget build(BuildContext context) => ProfileSurface(
    accent: accent,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            initial,
            style: ProfileTheme.heading.copyWith(fontSize: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: ProfileTheme.heading.copyWith(fontSize: 26)),
              const SizedBox(height: 5),
              Text(
                'Level 5 · $subject',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                university,
                style: const TextStyle(
                  fontSize: 12,
                  color: VectorColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SaudiMadeSignature extends StatelessWidget {
  const _SaudiMadeSignature();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 170,
          height: 68,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: 260,
              minWidth: 260,
              maxHeight: 260,
              minHeight: 260,
              child: Image.asset(
                'assets/logo/saudi-made.png',
                width: 260,
                height: 260,
                semanticLabel: 'Saudi Made logo',
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Made in Saudi Arabia',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VectorColors.saudiGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Saudi roots. Shared ambition.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VectorColors.textSecondary, fontSize: 12),
        ),
      ],
    ),
  );
}

class _VectorPaths extends CustomPainter {
  const _VectorPaths();
  @override
  void paint(Canvas canvas, Size size) {
    final end = Offset(size.width * .94, size.height * .35);
    for (final start in [
      Offset(0, size.height * .85),
      Offset(size.width * .2, 0),
    ]) {
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = VectorColors.apricot.withValues(alpha: .65)
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(start, 3, Paint()..color = VectorColors.apricot);
    }
    canvas.drawPath(
      Path()
        ..moveTo(end.dx - 11, end.dy - 7)
        ..lineTo(end.dx, end.dy)
        ..lineTo(end.dx - 11, end.dy + 7),
      Paint()
        ..color = VectorColors.apricot
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
