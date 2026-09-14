import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../widgets/vector_shapes.dart';

enum VectorLegalDocument { terms, privacy }

extension VectorLegalDocumentData on VectorLegalDocument {
  String get title {
    switch (this) {
      case VectorLegalDocument.terms:
        return 'Terms of Use';
      case VectorLegalDocument.privacy:
        return 'Privacy Policy';
    }
  }

  String get content {
    switch (this) {
      case VectorLegalDocument.terms:
        return _termsOfUse;

      case VectorLegalDocument.privacy:
        return _privacyPolicy;
    }
  }
}

Future<bool> showVectorLegalDocument(
  BuildContext context,
  VectorLegalDocument document,
) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundBright,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                const SizedBox(height: 22),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: AppTypography.display(size: 31, height: 1),
                        ),
                      ),

                      IconButton(
                        tooltip: 'Close',
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        icon: const Icon(Icons.close, color: AppColors.purple),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    child: Text(
                      document.content,
                      style: AppTypography.sans(
                        size: 14,
                        color: AppColors.muted,
                        height: 1.65,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                  child: _AgreeButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return accepted ?? false;
}

class _AgreeButton extends StatelessWidget {
  const _AgreeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Agree',
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
    );
  }
}

const String _termsOfUse = '''
Vector Terms of Use

Effective date: September 2026

By using Vector, you agree to use the platform responsibly and only for lawful purposes.

1. Account Information

You agree to provide accurate information when creating your account and to keep your login credentials secure.

You are responsible for activities performed through your account unless those activities result from a security issue outside your reasonable control.

2. User Profiles

You are responsible for the information, skills, links, files, and other material you choose to add to your Vector profile.

You should not submit information that you do not have permission to share.

3. Team Matching

Vector may use profile information, skills, interests, experience, project preferences, and similar information to help connect users with suitable teammates, teams, projects, and opportunities.

Matching suggestions are recommendations only. Vector does not guarantee that suggested users or teams will be suitable for you.

4. Acceptable Use

You may not use Vector to:

• Harass, threaten, or abuse other users.
• Impersonate another person or organization.
• Upload malicious or unlawful content.
• Attempt to interfere with the operation or security of the service.
• Access another person's account without authorization.
• Use the platform in violation of applicable laws.

5. Your Content

You retain ownership of content you create and upload to Vector.

You give Vector permission to process, store, and display that content only as reasonably necessary to provide and improve the service.

6. External Services

Profiles may contain links to third-party services such as GitHub and LinkedIn.

Vector does not control those services and is not responsible for their content, availability, privacy practices, or policies.

7. Platform Availability

Vector may modify, improve, suspend, or discontinue features when necessary.

We may also perform maintenance or make changes that temporarily affect availability.

8. Account Restrictions

Accounts that seriously or repeatedly violate these terms may be restricted, suspended, or removed.

9. Disclaimer

Vector is designed to help people discover potential teammates and collaborators.

Vector does not guarantee:

• Team compatibility.
• Employment opportunities.
• Project success.
• Hackathon results.
• Accuracy of information provided by other users.

10. Changes to These Terms

These Terms of Use may be updated as Vector develops.

When significant changes are made, users should be notified through an appropriate method.

By selecting Agree, you confirm that you have read and accepted these Terms of Use.
''';

const String _privacyPolicy = '''
Vector Privacy Policy

Effective date: September 2026

This Privacy Policy explains how Vector handles information used to create profiles, recommend teammates, and provide the platform.

1. Information You Provide

Vector may collect information that you provide directly, including:

• Your name.
• Email address.
• Skills.
• Interests.
• Experience.
• GitHub profile.
• LinkedIn profile.
• Project preferences.
• Team preferences.
• Evidence or certificates you choose to upload.

2. How Information Is Used

Your information may be used to:

• Create and maintain your account.
• Build your Vector profile.
• Recommend teammates and teams.
• Recommend projects or opportunities.
• Improve matching quality.
• Operate and improve Vector.
• Protect the security and integrity of the service.
• Communicate important account or service information.

3. Profile Visibility

Information that you intentionally place on your Vector profile may be visible to other Vector users depending on the platform's visibility settings.

You should avoid including information that you do not want other users to see.

4. Passwords and Authentication

Passwords should be handled through secure authentication systems.

Vector should never store passwords as readable plain text.

Passwords should be securely hashed or handled by an appropriate authentication provider.

5. GitHub and LinkedIn

If you choose to add a GitHub or LinkedIn profile, Vector may display the link as part of your profile.

GitHub and LinkedIn are independent third-party services and operate according to their own terms and privacy policies.

6. Team Matching

Vector may process profile information, skills, interests, experience, and preferences to recommend potentially suitable teammates or teams.

Automated recommendations are intended to assist discovery and should not be treated as guarantees of compatibility.

7. Data Retention

Information may be retained while your account remains active.

Certain information may also be retained for a reasonable period after account deletion where necessary for:

• Security.
• Fraud prevention.
• Legal compliance.
• Resolving disputes.
• Maintaining system integrity.

8. Your Choices

Where supported, you may:

• Update your profile information.
• Change information you have provided.
• Remove optional profile information.
• Request deletion of your account.

9. Security

Vector should use reasonable technical and organizational safeguards to protect user information.

However, no internet-based system can guarantee absolute security.

10. Policy Changes

This Privacy Policy may be updated as Vector develops and new functionality is introduced.

Significant changes should be communicated through an appropriate method.

By selecting Agree, you confirm that you have read and accepted this Privacy Policy.
''';
