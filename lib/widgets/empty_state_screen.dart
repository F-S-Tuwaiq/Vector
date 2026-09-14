import 'package:flutter/material.dart';

import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import 'vector_header.dart';

/// Shared in-theme empty-state pattern: slim purple header + centered
/// lavender icon tile, title, subtitle. Used for the Invites/Profile nav
/// tabs and the member-profile placeholder.
class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({
    super.key,
    required this.headerTitle,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
  });

  final String headerTitle;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VectorColors.background,
      body: Column(
        children: [
          VectorHeader.slim(
            title: headerTitle,
            showBackButton: showBackButton,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: VectorColors.surfaceLavender,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 28,
                        color: VectorColors.purpleBrand,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: VectorText.titleMedium.copyWith(
                        color: VectorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: VectorText.bodyMedium.copyWith(
                        color: VectorColors.textSecondary,
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
