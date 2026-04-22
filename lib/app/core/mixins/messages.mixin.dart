import 'package:flutter/material.dart';

mixin MessagesMixin {
  void showSuccess(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      backgroundColor: theme.colorScheme.primaryContainer,
      textColor: theme.colorScheme.onPrimaryContainer,
      icon: Icons.check_circle,
      iconColor: theme.colorScheme.primary,
    );
  }

  void showError(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      backgroundColor: theme.colorScheme.errorContainer,
      textColor: theme.colorScheme.onErrorContainer,
      icon: Icons.error_outline,
      iconColor: theme.colorScheme.error,
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
