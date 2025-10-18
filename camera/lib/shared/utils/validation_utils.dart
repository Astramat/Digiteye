/// Utilitaires de validation
class ValidationUtils {
  /// Validation d'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }
  
  /// Validation de mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre';
    }
    
    return null;
  }
  
  /// Validation de confirmation de mot de passe
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  /// Validation de nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
      return 'Le nom ne peut contenir que des lettres et espaces';
    }
    
    return null;
  }
  
  /// Validation de numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    
    final phoneRegex = RegExp(r'^(\+33|0)[1-9](\d{8})$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', '').replaceAll('-', ''))) {
      return 'Format de numéro de téléphone invalide';
    }
    
    return null;
  }
  
  /// Validation de champ requis
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }
  
  /// Validation de longueur minimale
  static String? validateMinLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Ce champ'} doit contenir au moins $minLength caractères';
    }
    
    return null;
  }
  
  /// Validation de longueur maximale
  static String? validateMaxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Ce champ'} ne peut pas dépasser $maxLength caractères';
    }
    
    return null;
  }
  
  /// Validation de longueur exacte
  static String? validateExactLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (value.length != length) {
      return '${fieldName ?? 'Ce champ'} doit contenir exactement $length caractères';
    }
    
    return null;
  }
  
  /// Validation de nombre
  static String? validateNumber(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Ce champ'} doit être un nombre valide';
    }
    
    return null;
  }
  
  /// Validation d'entier
  static String? validateInteger(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'Ce champ'} doit être un nombre entier';
    }
    
    return null;
  }
  
  /// Validation de plage de nombres
  static String? validateRange(String? value, double min, double max, [String? fieldName]) {
    final numberError = validateNumber(value, fieldName);
    if (numberError != null) return numberError;
    
    final num = double.parse(value!);
    if (num < min || num > max) {
      return '${fieldName ?? 'Ce champ'} doit être entre $min et $max';
    }
    
    return null;
  }
  
  /// Validation d'URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'URL est requise';
    }
    
    final urlRegex = RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');
    if (!urlRegex.hasMatch(value)) {
      return 'Format d\'URL invalide';
    }
    
    return null;
  }
  
  /// Validation de code postal français
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code postal est requis';
    }
    
    final postalRegex = RegExp(r'^\d{5}$');
    if (!postalRegex.hasMatch(value)) {
      return 'Le code postal doit contenir 5 chiffres';
    }
    
    return null;
  }
  
  /// Validation de date
  static String? validateDate(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'La date'} est requise';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Format de date invalide';
    }
  }
  
  /// Validation de date future
  static String? validateFutureDate(String? value, [String? fieldName]) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;
    
    final date = DateTime.parse(value!);
    if (date.isBefore(DateTime.now())) {
      return '${fieldName ?? 'La date'} doit être dans le futur';
    }
    
    return null;
  }
  
  /// Validation de date passée
  static String? validatePastDate(String? value, [String? fieldName]) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;
    
    final date = DateTime.parse(value!);
    if (date.isAfter(DateTime.now())) {
      return '${fieldName ?? 'La date'} doit être dans le passé';
    }
    
    return null;
  }
  
  /// Validation d'âge minimum
  static String? validateMinimumAge(String? value, int minAge, [String? fieldName]) {
    final dateError = validatePastDate(value, fieldName);
    if (dateError != null) return dateError;
    
    final date = DateTime.parse(value!);
    final age = DateTime.now().year - date.year;
    
    if (age < minAge) {
      return 'L\'âge minimum requis est $minAge ans';
    }
    
    return null;
  }
  
  /// Validation de sélection (pour les listes déroulantes, etc.)
  static String? validateSelection(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner ${fieldName ?? 'une option'}';
    }
    
    return null;
  }
  
  /// Validation de checkbox (pour les conditions d'utilisation, etc.)
  static String? validateCheckbox(bool? value, [String? fieldName]) {
    if (value != true) {
      return 'Vous devez accepter ${fieldName ?? 'les conditions'}';
    }
    
    return null;
  }
}
