class BarcodeParser {
  BarcodeParser._();

  // BPOM registration numbers, after whitespace is removed:
  // - NA18210100001, NKIT250001756 (Cosmetics)
  // - MD042867000101354 (Food, domestic), ML240935000701386 (Food, imported)
  // - TR123456789, POMTR122663051, SD123456789, SI214593251, QL012700041
  // - DKL2542601949B1 (Drugs)
  static final RegExp _bpomRegExp = RegExp(r'^[A-Z]{2,6}[0-9]{8,16}[A-Z0-9]{0,4}$');

  // AIM symbology identifier some scanners prepend, e.g. "]Q3" or "]d2".
  static final RegExp _symbologyPrefix = RegExp(r'^\][A-Za-z][0-9]');

  // GS1 AI (90) in human-readable form, terminated by the next "(" AI.
  static final RegExp _gs1Ai90Readable = RegExp(r'\(90\)([^(\x1D]+)');

  static final RegExp _retailBarcode = RegExp(r'^[0-9]{8,14}$');

  /// Extracts the bare registration number from raw scanner text or user input.
  ///
  /// BPOM 2D codes carry the number in GS1 AI (90) and may append other AIs
  /// such as (91) batch data; those must be stripped or the lookup returns
  /// no match and a genuine product is reported as unregistered.
  static String cleanCode(String input) {
    var cleaned = input.trim().replaceFirst(_symbologyPrefix, '');

    final readable = _gs1Ai90Readable.firstMatch(cleaned)?.group(1);
    if (readable != null) {
      cleaned = readable;
    } else if (RegExp(r'^90[A-Za-z]').hasMatch(cleaned)) {
      // Raw GS1 element string: AIs are separated by FNC1 (GS, 0x1D).
      cleaned = cleaned.substring(2).split('\x1D').first;
    }

    return normalize(cleaned);
  }

  /// Uppercases and removes all whitespace so numbers compare reliably.
  static String normalize(String code) {
    return code.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  /// True when the code is a retail EAN/UPC/GTIN, not a BPOM number.
  static bool isRetailBarcode(String code) => _retailBarcode.hasMatch(cleanCode(code));

  /// Verifies if a string is a valid-looking BPOM registration number
  static bool isValidBpomFormat(String code) {
    final cleaned = cleanCode(code);
    return cleaned.isNotEmpty && _bpomRegExp.hasMatch(cleaned);
  }

  /// Tries to extract BPOM registration number from parsed scanner text
  static String? extractRegistrationNumber(String scanResult) {
    final cleaned = cleanCode(scanResult);
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Compares two registration numbers, ignoring spacing and the optional
  /// "POM" prefix BPOM uses on some traditional-medicine numbers.
  static bool isSameRegistration(String a, String b) {
    String strip(String value) {
      final normalized = normalize(value);
      return normalized.startsWith('POM') ? normalized.substring(3) : normalized;
    }

    return strip(a) == strip(b);
  }
}
