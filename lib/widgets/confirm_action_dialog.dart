import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

Future<bool> showConfirmActionDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTypography.display(size: 30)),
        content: Text(
          message,
          style: AppTypography.sans(size: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.purple),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.apricot,
              foregroundColor: AppColors.purple,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ) ??
    false;
