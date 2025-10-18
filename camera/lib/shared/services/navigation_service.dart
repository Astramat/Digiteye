import 'package:flutter/material.dart';

/// Service de navigation global
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Retourne le contexte de navigation actuel
  static BuildContext get context => navigatorKey.currentContext!;
  
  /// Navigue vers une nouvelle page
  static Future<T?> push<T>(Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  /// Navigue vers une nouvelle page en remplaçant la page actuelle
  static Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  /// Navigue vers une nouvelle page en supprimant toutes les pages précédentes
  static Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
  
  /// Retourne à la page précédente
  static void pop<T>([T? result]) {
    Navigator.of(context).pop(result);
  }
  
  /// Retourne à la page précédente si possible
  static Future<bool> maybePop<T>([T? result]) {
    return Navigator.of(context).maybePop(result);
  }
  
  /// Vérifie si on peut revenir en arrière
  static bool canPop() {
    return Navigator.of(context).canPop();
  }
  
  /// Affiche une boîte de dialogue
  static Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
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
  
  /// Affiche un snackbar
  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
      ),
    );
  }
  
  /// Affiche un snackbar de succès
  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }
  
  /// Affiche un snackbar d'erreur
  static void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }
  
  /// Affiche un snackbar d'information
  static void showInfoSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue,
    );
  }
  
  /// Affiche un snackbar d'avertissement
  static void showWarningSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.orange,
    );
  }
}
