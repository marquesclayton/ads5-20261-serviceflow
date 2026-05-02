import 'package:flutter/material.dart';

/// Card customizado para listas de itens
class CustomListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isActive;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;

  const CustomListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isActive = true,
    this.margin,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: elevation ?? 2,
      color: backgroundColor ?? (isActive ? null : Colors.grey[100]),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Card customizado para avatares circulares
class CustomAvatarCard extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final String? imagePath;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double radius;
  final bool isActive;

  const CustomAvatarCard({
    super.key,
    required this.initials,
    this.imageUrl,
    this.imagePath,
    this.backgroundColor,
    this.foregroundColor,
    this.radius = 20,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? (isActive ? theme.primaryColor : Colors.grey),
      foregroundColor: foregroundColor ?? Colors.white,
      backgroundImage: _getBackgroundImage(),
      child: _getBackgroundImage() == null
          ? Text(
              initials.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (imageUrl != null) {
      return NetworkImage(imageUrl!);
    } else if (imagePath != null) {
      return AssetImage(imagePath!);
    }
    return null;
  }
}

/// Card de informações customizado
class CustomInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showDivider;

  const CustomInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: iconColor ?? theme.primaryColor,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

/// Card de status customizado
class CustomStatusCard extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomStatusCard({
    super.key,
    required this.label,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final MaterialColor color = isActive
        ? (activeColor as MaterialColor? ?? Colors.green)
        : (inactiveColor as MaterialColor? ?? Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[300]!),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color[700],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Card de empty state customizado
class CustomEmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color? iconColor;

  const CustomEmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
