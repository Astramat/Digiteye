/// Utilitaires pour les chaînes de caractères
class StringUtils {
  /// Capitalise la première lettre d'une chaîne
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Capitalise chaque mot d'une chaîne
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Supprime les espaces en début et fin
  static String trim(String text) {
    return text.trim();
  }
  
  /// Vérifie si une chaîne est vide ou ne contient que des espaces
  static bool isBlank(String? text) {
    return text == null || text.trim().isEmpty;
  }
  
  /// Vérifie si une chaîne n'est pas vide et ne contient pas que des espaces
  static bool isNotBlank(String? text) {
    return !isBlank(text);
  }
  
  /// Vérifie si une chaîne est un email valide
  static bool isEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Vérifie si une chaîne est un numéro de téléphone français valide
  static bool isFrenchPhone(String phone) {
    final phoneRegex = RegExp(r'^(\+33|0)[1-9](\d{8})$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''));
  }
  
  /// Vérifie si une chaîne est un code postal français valide
  static bool isFrenchPostalCode(String postalCode) {
    return RegExp(r'^\d{5}$').hasMatch(postalCode);
  }
  
  /// Masque un email (ex: j***@example.com)
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
  
  /// Masque un numéro de téléphone (ex: 06 ** ** ** 12)
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length >= 10) {
      return '${digits.substring(0, 2)} ** ** ** ${digits.substring(digits.length - 2)}';
    }
    
    return phone;
  }
  
  /// Tronque une chaîne à une longueur donnée
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  /// Supprime les caractères spéciaux d'une chaîne
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }
  
  /// Supprime les espaces multiples
  static String removeMultipleSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Formate un numéro avec des séparateurs de milliers
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]} ',
    );
  }
  
  /// Génère des initiales à partir d'un nom
  static String getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
  }
  
  /// Convertit une chaîne en slug (URL-friendly)
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Vérifie si une chaîne contient uniquement des lettres
  static bool isAlpha(String text) {
    return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(text);
  }
  
  /// Vérifie si une chaîne contient uniquement des chiffres
  static bool isNumeric(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }
  
  /// Vérifie si une chaîne contient uniquement des lettres et des chiffres
  static bool isAlphaNumeric(String text) {
    return RegExp(r'^[a-zA-ZÀ-ÿ0-9\s]+$').hasMatch(text);
  }
  
  /// Retourne le nombre de mots dans une chaîne
  static int wordCount(String text) {
    return text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
  
  /// Retourne le nombre de caractères (sans espaces)
  static int characterCount(String text) {
    return text.replaceAll(' ', '').length;
  }
  
  /// Vérifie si une chaîne commence par une majuscule
  static bool startsWithCapital(String text) {
    return text.isNotEmpty && text[0] == text[0].toUpperCase();
  }
  
  /// Inverse une chaîne
  static String reverse(String text) {
    return text.split('').reversed.join('');
  }
  
  /// Retourne une chaîne répétée n fois
  static String repeat(String text, int times) {
    return List.filled(times, text).join('');
  }
  
  /// Remplace les sauts de ligne par des balises HTML
  static String nl2br(String text) {
    return text.replaceAll('\n', '<br>');
  }
  
  /// Supprime les balises HTML d'une chaîne
  static String stripHtml(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
