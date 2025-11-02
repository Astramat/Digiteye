import 'package:flutter/material.dart';
import '../colors.dart';
import '../text_styles.dart';
import '../spacing.dart';
import '../border_radius.dart';

/// Couleurs pour le thème sombre
class DarkColors {
  // Couleurs de fond
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2D2D2D);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textLight = Color(0xFF808080);
  
  // Couleurs de bordure
  static const Color border = Color(0xFF404040);
  static const Color borderLight = Color(0xFF333333);
  static const Color borderDark = Color(0xFF555555);
  
  // Couleurs d'état
  static const Color hover = Color(0xFF2A2A2A);
  static const Color pressed = Color(0xFF1A1A1A);
}

/// Thème sombre de l'application
class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Couleurs du thème
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.textPrimary,
        error: AppColors.errorLight,
        onError: AppColors.textPrimary,
        surface: DarkColors.surface,
        onSurface: DarkColors.textPrimary,
        background: DarkColors.background,
        onBackground: DarkColors.textPrimary,
      ),
      
      // Couleurs personnalisées
      scaffoldBackgroundColor: DarkColors.background,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.surface,
        foregroundColor: DarkColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading6,
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingLG,
            vertical: AppSpacing.paddingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          elevation: 2,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingLG,
            vertical: AppSpacing.paddingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          side: const BorderSide(color: AppColors.primaryLight),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingMD,
            vertical: AppSpacing.paddingSM,
          ),
        ),
      ),
      
      // Champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.inputPadding),
        labelStyle: AppTextStyles.label.copyWith(color: DarkColors.textPrimary),
        hintStyle: AppTextStyles.body2.copyWith(color: DarkColors.textLight),
      ),

          
      // Cartes
      cardTheme: CardThemeData(
        color: DarkColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
        ),
        margin: const EdgeInsets.all(AppSpacing.paddingSM),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: DarkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
        ),
        titleTextStyle: AppTextStyles.heading5.copyWith(color: DarkColors.textPrimary),
        contentTextStyle: AppTextStyles.body1.copyWith(color: DarkColors.textPrimary),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: DarkColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: DarkColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // Icon
      iconTheme: const IconThemeData(
        color: DarkColors.textSecondary,
        size: 24,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: DarkColors.textPrimary),
        displayMedium: AppTextStyles.heading2.copyWith(color: DarkColors.textPrimary),
        displaySmall: AppTextStyles.heading3.copyWith(color: DarkColors.textPrimary),
        headlineLarge: AppTextStyles.heading4.copyWith(color: DarkColors.textPrimary),
        headlineMedium: AppTextStyles.heading5.copyWith(color: DarkColors.textPrimary),
        headlineSmall: AppTextStyles.heading6.copyWith(color: DarkColors.textPrimary),
        titleLarge: AppTextStyles.heading6.copyWith(color: DarkColors.textPrimary),
        titleMedium: AppTextStyles.body1.copyWith(color: DarkColors.textPrimary),
        titleSmall: AppTextStyles.body2.copyWith(color: DarkColors.textPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: DarkColors.textPrimary),
        bodyMedium: AppTextStyles.body2.copyWith(color: DarkColors.textPrimary),
        bodySmall: AppTextStyles.body3.copyWith(color: DarkColors.textPrimary),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.white),
        labelMedium: AppTextStyles.label.copyWith(color: DarkColors.textPrimary),
        labelSmall: AppTextStyles.caption.copyWith(color: DarkColors.textSecondary),
      ),
    );
  }
}
