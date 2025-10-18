import 'package:flutter/material.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';

/// Configuration principale des thèmes de l'application
class AppTheme {
  /// Thème clair
  static ThemeData get light => LightTheme.theme;
  
  /// Thème sombre
  static ThemeData get dark => DarkTheme.theme;
  
  /// Mode sombre par défaut
  static ThemeMode get defaultThemeMode => ThemeMode.system;
  
  /// Durée des transitions de thème
  static const Duration themeTransitionDuration = Duration(milliseconds: 300);
  
  /// Courbe d'animation des transitions
  static const Curve themeTransitionCurve = Curves.easeInOut;
}
