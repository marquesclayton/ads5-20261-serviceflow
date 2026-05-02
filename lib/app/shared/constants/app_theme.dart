import 'package:flutter/material.dart';

/// Cores customizadas da aplicação
class AppColors {
  // Cores principais
  static const Color primary = Color(0xFF2196F3); // Azul
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Cores de ação
  static const Color success = Color(0xFF4CAF50); // Verde
  static const Color warning = Color(0xFFFF9800); // Laranja
  static const Color danger = Color(0xFFF44336); // Vermelho
  static const Color info = Color(0xFF2196F3); // Azul claro

  // Cores neutras
  static const Color light = Color(0xFFF5F5F5);
  static const Color dark = Color(0xFF212121);
  static const Color muted = Color(0xFF9E9E9E);

  // Estados
  static const Color active = success;
  static const Color inactive = muted;

  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Cores de fundo
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF303030);

  // Cores de borda
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Cores de shadow
  static const Color shadow = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);
}

/// Estilos de texto customizados
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );
}

/// Espacamentos e tamanhos padronizados
class AppSizes {
  // Padding e margin
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius
  static const double radiusSmall = 6.0;
  static const double radius = 12.0;
  static const double radiusLarge = 16.0;

  // Elevação
  static const double elevationLow = 2.0;
  static const double elevation = 4.0;
  static const double elevationHigh = 8.0;

  // Tamanhos de ícones
  static const double iconSmall = 16.0;
  static const double icon = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Tamanhos de avatar
  static const double avatarSmall = 32.0;
  static const double avatar = 40.0;
  static const double avatarLarge = 56.0;

  // Alturas de componentes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double textFieldHeight = 56.0;
  static const double appBarHeight = 56.0;
}
