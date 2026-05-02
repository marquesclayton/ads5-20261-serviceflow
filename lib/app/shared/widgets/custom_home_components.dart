import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/// AppBar customizado com gradiente
class CustomGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color startColor;
  final Color endColor;
  final VoidCallback? onLogout;

  const CustomGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.startColor = Colors.indigo,
    this.endColor = Colors.indigo,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: actions ??
            [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout,
              ),
            ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Header de boas-vindas customizado
class CustomWelcomeHeader extends StatelessWidget {
  final String welcomeText;
  final String subtitleText;
  final Color textColor;
  final Color subtitleColor;

  const CustomWelcomeHeader({
    super.key,
    this.welcomeText = 'Bem-vindo!',
    this.subtitleText = 'Escolha uma opção para começar',
    this.textColor = Colors.white,
    this.subtitleColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text(
          welcomeText,
          style: AppTextStyles.h1.copyWith(color: textColor),
        ),
        Text(
          subtitleText,
          style: AppTextStyles.bodyLarge.copyWith(color: subtitleColor),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }
}

/// Card de menu customizado com gradiente
class CustomMenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CustomMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSizes.iconXLarge,
                color: AppColors.textLight,
              ),
              const SizedBox(height: AppSizes.sm),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Flexible(
                child: Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid de menu customizado
class CustomMenuGrid extends StatelessWidget {
  final List<CustomMenuCard> menuItems;
  final int crossAxisCount;
  final double spacing;

  const CustomMenuGrid({
    super.key,
    required this.menuItems,
    this.crossAxisCount = 2,
    this.spacing = AppSizes.md,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      children: menuItems,
    );
  }
}

/// Botão de ação rápida customizado
class CustomQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const CustomQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.indigo,
    this.textColor = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconLarge,
              color: iconColor,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel de ações rápidas customizado
class CustomQuickActionsPanel extends StatelessWidget {
  final List<CustomQuickActionButton> actions;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const CustomQuickActionsPanel({
    super.key,
    required this.actions,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.elevationHigh,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions,
      ),
    );
  }
}

/// Container com gradiente de fundo customizado
class CustomGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final List<double>? stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const CustomGradientBackground({
    super.key,
    required this.child,
    this.colors = const [Colors.indigo, Colors.white],
    this.stops = const [0.3, 1.0],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
      ),
      child: child,
    );
  }
}
