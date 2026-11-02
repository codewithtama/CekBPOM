class HalalCheckResult {
  final String query;
  final String status; // 'TERDAFTAR RESMI', 'PERLU VERIFIKASI', 'TIDAK TERDAFTAR'
  final bool isCertified;
  final String agency; // 'BPJPH Kemenag RI / LPPOM MUI'
  final String officialVerificationUrl;
  final String description;

  const HalalCheckResult({
    required this.query,
    required this.status,
    required this.isCertified,
    required this.agency,
    required this.officialVerificationUrl,
    required this.description,
  });
}

