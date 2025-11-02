import 'package:intl/intl.dart';

/// Formateurs pour l'affichage des données
class Formatters {
  /// Formatage de devise (Euro par défaut)
  static String currency(double amount, {String symbol = '€'}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  /// Formatage de nombre avec séparateurs
  static String number(double number, {int decimalDigits = 0}) {
    final formatter = NumberFormat('#,##0${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}', 'fr_FR');
    return formatter.format(number);
  }
  
  /// Formatage de pourcentage
  static String percentage(double value, {int decimalDigits = 1}) {
    final formatter = NumberFormat('#,##0${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}%', 'fr_FR');
    return formatter.format(value / 100);
  }
  
  /// Formatage de date
  static String date(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(pattern, 'fr_FR');
    return formatter.format(date);
  }
  
  /// Formatage de date et heure
  static String dateTime(DateTime dateTime, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    final formatter = DateFormat(pattern, 'fr_FR');
    return formatter.format(dateTime);
  }
  
  /// Formatage de date relative (il y a X jours)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return Formatters.date(date);
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
  
  /// Formatage de durée
  static String duration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  /// Formatage de taille de fichier
  static String fileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int suffixIndex = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }
    
    return '${number(size, decimalDigits: 1)} ${suffixes[suffixIndex]}';
  }
  
  /// Formatage de numéro de téléphone français
  static String phoneNumber(String phone) {
    // Supprime tous les caractères non numériques
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 10 && digits.startsWith('0')) {
      return '${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    } else if (digits.length == 12 && digits.startsWith('33')) {
      final nationalNumber = digits.substring(2);
      return '+33 ${nationalNumber.substring(0, 1)} ${nationalNumber.substring(1, 3)} ${nationalNumber.substring(3, 5)} ${nationalNumber.substring(5, 7)} ${nationalNumber.substring(7)}';
    }
    
    return phone; // Retourne tel quel si le format n'est pas reconnu
  }
  
  /// Formatage de nom avec initiales
  static String initials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
  }
  
  /// Formatage de texte avec capitalisation
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Formatage de texte avec capitalisation de chaque mot
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Masquage d'email (ex: j***@example.com)
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '***@$domain';
    }
    
    return '${username[0]}***${username[username.length - 1]}@$domain';
  }
  
  /// Masquage de numéro de téléphone (ex: 06 ** ** ** 12)
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length >= 10) {
      return '${digits.substring(0, 2)} ** ** ** ${digits.substring(digits.length - 2)}';
    }
    
    return phone;
  }
}
