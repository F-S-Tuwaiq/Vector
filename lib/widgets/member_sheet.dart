import 'package:flutter/material.dart';

import '../models/member.dart';
import '../screens/profile_screen.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

/// The one reusable bottom sheet for tapping any member tile, anywhere.
Future<void> showMemberSheet(BuildContext context, Member member) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: VectorColors.surfaceWhite,
    barrierColor: VectorColors.dialogBarrier,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (context) => _MemberSheetContent(member: member),
  );
}

class _MemberSheetContent extends StatelessWidget {
  const _MemberSheetContent({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final TextStyle metaStyle = VectorText.bodyMedium.copyWith(
      color: VectorColors.textSecondary,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: VectorColors.surfaceLavender,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VectorColors.surfaceLavender,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    member.initials,
                    style: VectorText.titleLarge.copyWith(
                      color: VectorColors.purpleBrand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: VectorText.headlineMedium.copyWith(
                          fontSize: 20,
                          color: VectorColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(member.role, style: metaStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (member.city.isNotEmpty) ...[
                  Text(member.city, style: metaStyle),
                  const _MetaDivider(),
                ],
                Text('${member.hackathons} hackathons', style: metaStyle),
                if (member.lead) ...[
                  const _MetaDivider(),
                  Text('Team lead', style: metaStyle),
                ],
              ],
            ),
            if (member.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: member.skills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: ShapeDecoration(
                          color: VectorColors.surfaceLavender,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          skill,
                          style: VectorText.labelSmall.copyWith(
                            color: VectorColors.textSecondaryPurple,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(member: member),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VectorColors.purpleBrand,
                  foregroundColor: VectorColors.textOnPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  'View full profile',
                  style: VectorText.labelLarge.copyWith(
                    color: VectorColors.textOnPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: VectorColors.hairline,
    );
  }
}
