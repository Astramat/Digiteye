import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Extensions pour les types de base

/// Extension pour String
extension StringExtensions on String {
  /// Vérifie si la chaîne est un email valide
  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  /// Vérifie si la chaîne est un numéro de téléphone français valide
  bool get isFrenchPhone {
    final phoneRegex = RegExp(r'^(\+33|0)[1-9](\d{8})$');
    return phoneRegex.hasMatch(replaceAll(' ', '').replaceAll('-', ''));
  }
  
  /// Vérifie si la chaîne est un code postal français valide
  bool get isFrenchPostalCode {
    return RegExp(r'^\d{5}$').hasMatch(this);
  }
  
  /// Capitalise la première lettre
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
  
  /// Capitalise chaque mot
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// Supprime les espaces en début et fin
  String get trimSpaces => trim();
  
  /// Vérifie si la chaîne est vide ou ne contient que des espaces
  bool get isBlank => trim().isEmpty;
  
  /// Vérifie si la chaîne n'est pas vide et ne contient pas que des espaces
  bool get isNotBlank => !isBlank;
  
  /// Masque l'email (ex: j***@example.com)
  String get maskEmail {
    if (!contains('@')) return this;
    
    final parts = split('@');
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '***@$domain';
    }
    
    return '${username[0]}***${username[username.length - 1]}@$domain';
  }
}

/// Extension pour DateTime
extension DateTimeExtensions on DateTime {
  /// Vérifie si la date est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Vérifie si la date est hier
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Vérifie si la date est cette semaine
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// Vérifie si la date est ce mois
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
  
  /// Vérifie si la date est cette année
  bool get isThisYear {
    return year == DateTime.now().year;
  }
  
  /// Retourne le début du jour
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }
  
  /// Retourne la fin du jour
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
  
  /// Retourne le début de la semaine
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1));
  }
  
  /// Retourne la fin de la semaine
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday));
  }
  
  /// Retourne le début du mois
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }
  
  /// Retourne la fin du mois
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0);
  }
}

/// Extension pour int
extension IntExtensions on int {
  /// Formate le nombre avec des séparateurs de milliers
  String get formatWithSeparator {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]} ',
    );
  }
  
  /// Retourne le nombre avec un suffixe ordinal (1er, 2ème, etc.)
  String get ordinal {
    if (this == 1) return '${this}er';
    return '${this}ème';
  }
  
  /// Retourne le nombre en format de durée (1h 30m)
  String get asDuration {
    final hours = this ~/ 60;
    final minutes = this % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Extension pour double
extension DoubleExtensions on double {
  /// Arrondit à n décimales
  double roundTo(int decimals) {
    final factor = math.pow(10, decimals);
    return (this * factor).round() / factor;
  }
  
  /// Formate en pourcentage
  String get asPercentage {
    return '${(this * 100).roundTo(1)}%';
  }
  
  /// Formate en devise (€)
  String get asCurrency {
    return '${roundTo(2)}€';
  }
}

/// Extension pour BuildContext
extension BuildContextExtensions on BuildContext {
  /// Retourne la largeur de l'écran
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Retourne la hauteur de l'écran
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Retourne la densité de pixels
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;
  
  /// Vérifie si l'écran est petit
  bool get isSmallScreen => screenWidth < 600;
  
  /// Vérifie si l'écran est moyen
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1024;
  
  /// Vérifie si l'écran est grand
  bool get isLargeScreen => screenWidth >= 1024;
  
  /// Retourne le thème
  ThemeData get theme => Theme.of(this);
  
  /// Retourne les couleurs du thème
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Retourne les styles de texte
  TextTheme get textTheme => theme.textTheme;
  
  /// Retourne si le thème est sombre
  bool get isDarkTheme => theme.brightness == Brightness.dark;
  
  /// Navigue vers une page
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  /// Navigue vers une page en remplaçant la page actuelle
  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  /// Retourne à la page précédente
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
  
  /// Affiche un snackbar
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  /// Affiche une boîte de dialogue
  Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

