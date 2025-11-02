/// Validateurs pour les champs de formulaire
class Validators {
  /// Validation d'email
  static String? email(String? value) {
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
  static String? password(String? value) {
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
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  /// Validation de nom
  static String? name(String? value) {
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
  static String? phone(String? value) {
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
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }
  
  /// Validation de longueur minimale
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Ce champ'} doit contenir au moins $minLength caractères';
    }
    
    return null;
  }
  
  /// Validation de longueur maximale
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Ce champ'} ne peut pas dépasser $maxLength caractères';
    }
    
    return null;
  }
  
  /// Validation de longueur exacte
  static String? exactLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (value.length != length) {
      return '${fieldName ?? 'Ce champ'} doit contenir exactement $length caractères';
    }
    
    return null;
  }
  
  /// Validation de nombre
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Ce champ'} doit être un nombre valide';
    }
    
    return null;
  }
  
  /// Validation d'entier
  static String? integer(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'Ce champ'} doit être un nombre entier';
    }
    
    return null;
  }
  
  /// Validation d'URL
  static String? url(String? value) {
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
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code postal est requis';
    }
    
    final postalRegex = RegExp(r'^\d{5}$');
    if (!postalRegex.hasMatch(value)) {
      return 'Le code postal doit contenir 5 chiffres';
    }
    
    return null;
  }
}
