/// Input validation utilities for all forms
/// Provides reusable validators for email, password, phone, etc.
class AppValidators {
  AppValidators._();

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // RFC 5322 simplified regex
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for uppercase
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    
    // Check for lowercase
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    
    // Check for number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    
    // Check for special character
    if (!value.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:,.<>?/|`~]'))) {
      return 'Password must contain a special character (!@#\$%^&*)';
    }
    
    return null;
  }

  /// Validate phone number (Bangladesh format)
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces, dashes, parentheses
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-()]+'), '');
    
    // Bangladesh phone formats:
    // +880XXXXXXXXXX or 0XXXXXXXXXX or 88XXXXXXXXXX
    final phoneRegex = RegExp(r'^(\+880|0|88)1[3-9]\d{8}$');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid Bangladesh phone number';
    }
    
    return null;
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    
    // Allow letters, spaces, hyphens, apostrophes (supports Bengali)
    final nameRegex = RegExp(r"^[\p{L}\s\-']+$", unicode: true);
    
    if (!nameRegex.hasMatch(value)) {
      return 'Name contains invalid characters';
    }
    
    return null;
  }

  /// Validate not empty
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validate maximum length
  String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    
    return null;
  }

  /// Validate URL
  String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    try {
      Uri.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  /// Validate amount (numeric, positive)
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    return null;
  }

  /// Validate quantity
  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    
    final qty = int.tryParse(value);
    if (qty == null) {
      return 'Please enter a valid quantity';
    }
    
    if (qty <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    return null;
  }

  /// Validate confirm password matches
  String? validatePasswordMatch(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}
