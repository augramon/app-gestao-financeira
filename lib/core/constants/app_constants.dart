import 'package:flutter/material.dart';

/// Constantes centrais do aplicativo.
///
/// O nome do app fica aqui para facilitar alteração futura.
class AppConstants {
  AppConstants._();

  /// Nome provisório do aplicativo.
  static const String appName = 'Spendly';
  static const String appTagline = 'Controle seus gastos com clareza';
  static const String appVersion = '1.0.0';

  /// Moeda padrão do MVP.
  static const String currencyLocale = 'pt_BR';
  static const String currencySymbol = 'R\$';

  /// Espaçamentos padrão (layout generoso e consistente).
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  /// Raio de borda padrão dos cards e botões.
  static const double radius = 16;
  static const double radiusSm = 12;

  /// Duração padrão de microinterações.
  static const Duration shortAnimation = Duration(milliseconds: 200);
}

/// Cores da marca usadas como base da paleta Material 3.
class AppColors {
  AppColors._();

  /// Cor primária: verde moderno e discreto.
  static const Color seed = Color(0xFF1B8A5A);
  static const Color positive = Color(0xFF1B8A5A);
  static const Color alert = Color(0xFFE5484D);

  /// Paleta discreta para categorias (usada como sugestão de cores).
  static const List<Color> categoryPalette = [
    Color(0xFF1B8A5A), // verde
    Color(0xFF2563EB), // azul
    Color(0xFFF59E0B), // âmbar
    Color(0xFF8B5CF6), // roxo
    Color(0xFFEC4899), // rosa
    Color(0xFF0EA5E9), // ciano
    Color(0xFFEF4444), // vermelho
    Color(0xFF14B8A6), // teal
    Color(0xFF6366F1), // índigo
    Color(0xFF84CC16), // lima
    Color(0xFFF97316), // laranja
    Color(0xFF64748B), // cinza
  ];
}
