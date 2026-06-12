class BarcodeParser {
  BarcodeParser._();

  // Pattern for BPOM registration numbers
  // Examples:
  // - NA18210100001, NKIT250001756 (Cosmetics)
  // - MD 234567890123 (Food Domestic)
  // - ML 123456789012 (Food Importer)
  // - TR123456789, SD123456789 (Traditional medicine, supplements)
  // - DKL1234567890A1 (Drugs)
  static final RegExp _bpomRegExp = RegExp(
    r'\b([A-Z]{2,4})\s*([0-9]{9,12}[A-Z0-9]*)\b',
    caseSensitive: false,
  );

  /// Cleans the input code (removing whitespace, brackets, special prefixes like (90) for GS1)
  static String cleanCode(String input) {
    String cleaned = input.trim();
    
    // Check if it has GS1 AI (90) prefix: (90)NA18210100001 or 90NA18210100001
    if (cleaned.startsWith('(90)')) {
      cleaned = cleaned.substring(4);
    } else if (cleaned.startsWith('90') && cleaned.length > 10 && !cleaned.substring(2, 4).contains(RegExp(r'[0-9]'))) {
      // 90 followed by non-digits usually implies AI (90)
      cleaned = cleaned.substring(2);
    }

    // Remove any formatting spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    return cleaned.toUpperCase();
  }

  /// Verifies if a string is a valid-looking BPOM registration number
  static bool isValidBpomFormat(String code) {
    final cleaned = cleanCode(code);
    if (cleaned.isEmpty) return false;
    
    // Check general length and characters
    // Typically starts with 2-4 letters followed by 9-12 numbers/alphanumerics
    return _bpomRegExp.hasMatch(cleaned);
  }

  /// Tries to extract BPOM registration number from parsed scanner text
  static String? extractRegistrationNumber(String scanResult) {
    final cleaned = cleanCode(scanResult);
    final match = _bpomRegExp.firstMatch(cleaned);
    if (match != null) {
      return match.group(0);
    }
    
    // Fallback: if it's just numbers, it might be EAN-13 barcode
    return cleaned;
  }
}
