import 'package:flutter/material.dart';

/// Item customizado para PopupMenuButton com ícone e texto padronizados
class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  CustomPopupMenuItem({
    required T value,
    required String text,
    required IconData icon,
    Color? iconColor,
    bool enabled = true,
    super.key,
  }) : super(
          value: value,
          enabled: enabled,
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? _getDefaultIconColor(value.toString()),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: enabled ? null : Colors.grey[400],
                ),
              ),
            ],
          ),
        );

  /// Cores padrão baseadas na ação
  static Color _getDefaultIconColor(String action) {
    switch (action.toLowerCase()) {
      case 'editar':
      case 'edit':
        return Colors.blue;
      case 'ativar':
      case 'activate':
        return Colors.green;
      case 'desativar':
      case 'deactivate':
      case 'inactive':
        return Colors.orange;
      case 'excluir':
      case 'delete':
      case 'remover':
        return Colors.red;
      case 'visualizar':
      case 'view':
      case 'detalhes':
        return Colors.grey[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}

/// PopupMenuButton customizado com ações comuns de CRUD
class CrudPopupMenuButton<T> extends StatelessWidget {
  final T item;
  final bool isActive;
  final Function(String action) onSelected;
  final List<CustomPopupMenuAction>? customActions;
  final bool showEdit;
  final bool showActivate;
  final bool showDelete;
  final bool showDetails;

  const CrudPopupMenuButton({
    super.key,
    required this.item,
    required this.isActive,
    required this.onSelected,
    this.customActions,
    this.showEdit = true,
    this.showActivate = true,
    this.showDelete = true,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      onSelected: onSelected,
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // Ação de editar
        if (showEdit) {
          items.add(
            CustomPopupMenuItem<String>(
              value: 'editar',
              text: 'Editar',
              icon: Icons.edit,
              iconColor: Colors.blue,
            ),
          );
        }

        // Ação de ativar/desativar
        if (showActivate) {
          items.add(
            CustomPopupMenuItem<String>(
              value: isActive ? 'desativar' : 'ativar',
              text: isActive ? 'Desativar' : 'Ativar',
              icon: isActive ? Icons.visibility_off : Icons.visibility,
              iconColor: isActive ? Colors.orange : Colors.green,
            ),
          );
        }

        // Ação de detalhes
        if (showDetails) {
          items.add(
            CustomPopupMenuItem<String>(
              value: 'detalhes',
              text: 'Ver Detalhes',
              icon: Icons.info_outline,
              iconColor: Colors.blue,
            ),
          );
        }

        // Ações customizadas
        if (customActions != null) {
          for (var action in customActions!) {
            items.add(
              CustomPopupMenuItem<String>(
                value: action.value,
                text: action.text,
                icon: action.icon,
                iconColor: action.color,
                enabled: action.enabled,
              ),
            );
          }
        }

        // Divisor antes da ação destrutiva
        if (items.isNotEmpty && showDelete) {
          items.add(const PopupMenuDivider());
        }

        // Ação de excluir (sempre por último)
        if (showDelete) {
          items.add(
            CustomPopupMenuItem<String>(
              value: 'excluir',
              text: 'Excluir',
              icon: Icons.delete_outline,
              iconColor: Colors.red,
            ),
          );
        }

        return items;
      },
    );
  }
}

/// Classe para definir ações customizadas no popup menu
class CustomPopupMenuAction {
  final String value;
  final String text;
  final IconData icon;
  final Color? color;
  final bool enabled;

  const CustomPopupMenuAction({
    required this.value,
    required this.text,
    required this.icon,
    this.color,
    this.enabled = true,
  });
}

/// PopupMenuButton para filtros (mostrar/ocultar itens)
class FilterPopupMenuButton extends StatelessWidget {
  final bool showInactive;
  final Function(bool showInactive) onChanged;
  final String activeLabel;
  final String inactiveLabel;

  const FilterPopupMenuButton({
    super.key,
    required this.showInactive,
    required this.onChanged,
    this.activeLabel = 'Apenas Ativos',
    this.inactiveLabel = 'Mostrar Inativos',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        showInactive ? Icons.visibility : Icons.visibility_off,
        color: Colors.white,
      ),
      tooltip: showInactive ? 'Filtrar apenas ativos' : 'Mostrar todos',
      onSelected: (value) {
        onChanged(value == 'todos');
      },
      itemBuilder: (context) => [
        CustomPopupMenuItem<String>(
          value: 'todos',
          text: inactiveLabel,
          icon: showInactive ? Icons.check_box : Icons.check_box_outline_blank,
          iconColor: Colors.blue,
        ),
        CustomPopupMenuItem<String>(
          value: 'ativos',
          text: activeLabel,
          icon: !showInactive ? Icons.check_box : Icons.check_box_outline_blank,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}
