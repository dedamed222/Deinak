class ValidationUtils {
  /// Validates Mauritanian phone numbers: 8 digits starting with 2, 3, or 4.
  static bool isValidMauritanianPhone(String phone) {
    if (phone.isEmpty) return false;
    // Regex for 8 digits starting with 2, 3, or 4
    final phoneRegex = RegExp(r'^[234]\d{7}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Returns null if valid, or a localized error message.
  /// This is a helper for TextFormField validators that takes the l10n strings.
  static String? validatePhone(
      String? value, String requiredMsg, String invalidMsg) {
    if (value == null || value.isEmpty) {
      return requiredMsg;
    }
    if (!isValidMauritanianPhone(value.trim())) {
      return invalidMsg;
    }
    return null;
  }
}
