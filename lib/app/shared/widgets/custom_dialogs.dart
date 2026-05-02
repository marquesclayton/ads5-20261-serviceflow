import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/custom_buttons.dart';

/// Dialog customizado para confirmações
class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final CustomButtonVariant confirmVariant;
  final IconData? icon;
  final Color? iconColor;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.confirmVariant = CustomButtonVariant.primary,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? _getVariantColor(confirmVariant),
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        CustomSecondaryButton(
          text: cancelText,
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          width: null,
        ),
        const SizedBox(width: 8),
        CustomActionButton(
          text: confirmText,
          variant: confirmVariant,
          onPressed: onConfirm,
          width: null,
        ),
      ],
    );
  }

  Color _getVariantColor(CustomButtonVariant variant) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return Colors.blue;
      case CustomButtonVariant.success:
        return Colors.green;
      case CustomButtonVariant.warning:
        return Colors.orange;
      case CustomButtonVariant.danger:
        return Colors.red;
      case CustomButtonVariant.secondary:
        return Colors.grey;
    }
  }

  /// Método estático para mostrar dialog de confirmação de exclusão
  static Future<bool?> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: 'Confirmar Exclusão Permanente',
        content: customMessage ??
            'Deseja realmente excluir permanentemente $itemName? Esta ação não pode ser desfeita.',
        confirmText: 'Excluir',
        cancelText: 'Cancelar',
        confirmVariant: CustomButtonVariant.danger,
        icon: Icons.delete_forever,
        iconColor: Colors.red,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Método estático para mostrar dialog de confirmação de desativação
  static Future<bool?> showDeactivateConfirmation(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: 'Confirmar Desativação',
        content: customMessage ??
            'Deseja desativar $itemName? Você pode reativá-lo depois.',
        confirmText: 'Desativar',
        cancelText: 'Cancelar',
        confirmVariant: CustomButtonVariant.warning,
        icon: Icons.block,
        iconColor: Colors.orange,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Método estático para mostrar dialog genérico
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    CustomButtonVariant confirmVariant = CustomButtonVariant.primary,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmVariant: confirmVariant,
        icon: icon,
        iconColor: iconColor,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }
}

/// Dialog customizado para mostrar detalhes
class CustomInfoDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;

  const CustomInfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? theme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: content,
      actions: actions ??
          [
            CustomSecondaryButton(
              text: 'Fechar',
              onPressed: () => Navigator.of(context).pop(),
              width: null,
            ),
          ],
    );
  }
}
