import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/// Item do drawer customizado
class CustomDrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final Color? iconColor;
  final Color? textColor;

  const CustomDrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    this.iconColor,
    this.textColor,
  });
}

/// Header customizado do drawer
class CustomDrawerHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? avatar;
  final List<Color> gradientColors;

  const CustomDrawerHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatar,
    this.gradientColors = const [Colors.indigo, Colors.blue],
  });

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar ??
              CircleAvatar(
                radius: AppSizes.avatarLarge / 2,
                backgroundColor: AppColors.backgroundPrimary,
                child: Icon(
                  Icons.person,
                  size: AppSizes.iconLarge,
                  color: gradientColors.first,
                ),
              ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(color: AppColors.textLight),
          ),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer customizado da aplicação
class CustomAppDrawer extends StatelessWidget {
  final String appTitle;
  final String appSubtitle;
  final Widget? headerAvatar;
  final List<Color> headerGradientColors;
  final List<CustomDrawerItem> menuItems;
  final List<CustomDrawerItem> configurationItems;
  final VoidCallback? onLogout;

  const CustomAppDrawer({
    super.key,
    this.appTitle = 'ServiceFlow',
    this.appSubtitle = 'Sistema de Gestão',
    this.headerAvatar,
    this.headerGradientColors = const [Colors.indigo, Colors.blue],
    this.menuItems = const [],
    this.configurationItems = const [],
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomDrawerHeader(
            title: appTitle,
            subtitle: appSubtitle,
            avatar: headerAvatar,
            gradientColors: headerGradientColors,
          ),
          // Itens do menu principal
          ...menuItems.map((item) => _buildDrawerItem(context, item)),
          // Divider se há itens de configuração
          if (configurationItems.isNotEmpty) const Divider(),
          // Itens de configuração
          ...configurationItems.map((item) => _buildDrawerItem(context, item)),
          // Botão de logout se fornecido
          if (onLogout != null) ...[
            const Divider(),
            _buildLogoutItem(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, CustomDrawerItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.iconColor,
      ),
      title: Text(
        item.title,
        style: item.textColor != null ? TextStyle(color: item.textColor) : null,
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, item.route);
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: AppColors.danger,
      ),
      title: Text(
        'Sair',
        style: TextStyle(color: AppColors.danger),
      ),
      onTap: () {
        Navigator.pop(context);
        onLogout?.call();
      },
    );
  }

  /// Factory method para criar drawer padrão do ServiceFlow
  factory CustomAppDrawer.serviceFlow({
    VoidCallback? onLogout,
  }) {
    return CustomAppDrawer(
      appTitle: 'ServiceFlow',
      appSubtitle: 'Sistema de Gestão',
      menuItems: [
        CustomDrawerItem(
          icon: Icons.people,
          title: 'Clientes',
          route: '/clientes',
        ),
        CustomDrawerItem(
          icon: Icons.build,
          title: 'Ordens de Serviço',
          route: '/ordens-servico',
        ),
        CustomDrawerItem(
          icon: Icons.bar_chart,
          title: 'Relatórios',
          route: '/relatorios',
        ),
        CustomDrawerItem(
          icon: Icons.inventory,
          title: 'Estoque',
          route: '/estoque',
        ),
        CustomDrawerItem(
          icon: Icons.science,
          title: 'Laboratório',
          route: '/menu-lab',
        ),
      ],
      configurationItems: [
        CustomDrawerItem(
          icon: Icons.settings,
          title: 'Configurações',
          route: '/configuracoes',
        ),
      ],
      onLogout: onLogout,
    );
  }
}
