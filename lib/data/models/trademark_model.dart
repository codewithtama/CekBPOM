/// Represents a registered Indonesian trademark (Hak Kekayaan Intelektual / HKI)
/// from the DJKI Kemenkumham database via the haki.id API.
class TrademarkModel {
  const TrademarkModel({
    required this.id,
    required this.mark,
    required this.applicant,
    required this.registrationNumber,
    required this.fillingNumber,
    required this.fillingDate,
    required this.registrationDate,
    required this.expirationDate,
    required this.niceClasses,
    required this.status,
    required this.logoUrl,
    required this.pdkiLink,
    required this.applicantAddress,
    required this.goodsServices,
  });

  final String id;
  final String mark;
  final String applicant;
  final String registrationNumber;
  final String fillingNumber;
  final String fillingDate;
  final String registrationDate;
  final String expirationDate;
  final String niceClasses;
  final String status;
  final String? logoUrl;
  final String? pdkiLink;
  final String applicantAddress;
  final String goodsServices;

  /// Returns true if status represents an officially registered trademark.
  bool get isRegistered =>
      status.toLowerCase().contains('didaftar') ||
      status.toLowerCase().contains('registered');

  /// Helper to get a human-friendly description for common Nice Classifications.
  String get classDescription {
    switch (niceClasses.trim()) {
      case '3':
        return 'Kelas 3 (Kosmetik, Sabun, Skincare & Parfum)';
      case '5':
        return 'Kelas 5 (Farmasi, Obat-obatan, Vitamin & Suplemen)';
      case '29':
        return 'Kelas 29 (Olahan Daging, Susu, Minyak & Pangan Awetan)';
      case '30':
        return 'Kelas 30 (Kopi, Teh, Mi Instan, Bumbu & Roti)';
      case '32':
        return 'Kelas 32 (Minuman Non-Alkohol, Air Mineral & Jus)';
      case '33':
        return 'Kelas 33 (Minuman Beralkohol)';
      case '34':
        return 'Kelas 34 (Tembakau, Rokok & Perlengkapan Perokok)';
      case '35':
        return 'Kelas 35 (Periklanan, Manajemen Bisnis & Toko Retail)';
      default:
        return niceClasses.isNotEmpty ? 'Kelas $niceClasses' : '-';
    }
  }

  /// Parses a [TrademarkModel] from JSON returned by `haki.id/api/trademarks`.
  factory TrademarkModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] as String? ?? '';
    final tableData = json['TableData'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final mark = (tableData['mark'] as String? ?? '').trim();
    final applicant = (tableData['applicant'] as String? ?? '').trim();
    final regNo = (tableData['registration_number'] as String? ?? '').trim();
    final fillNo = (tableData['filling_number_text'] as String? ?? '').trim();
    final fillDate = (tableData['filling_date'] as String? ?? '').trim();
    final regDate = (tableData['registration_date'] as String? ?? '').trim();
    final expDate = (tableData['expiration_date'] as String? ?? '').trim();
    final classes = (tableData['nice_classes'] as String? ?? '').trim();
    final status = (tableData['status'] as String? ?? '').trim();
    final rawLogo = tableData['logo_url'] as String?;
    final link = tableData['link'] as String?;
    final address = (tableData['applicant_address'] as String? ?? '').trim();
    final services = (tableData['goods_services'] as String? ?? '').trim();

    String? fullLogoUrl;
    if (rawLogo != null && rawLogo.isNotEmpty) {
      if (rawLogo.startsWith('http')) {
        fullLogoUrl = rawLogo;
      } else {
        fullLogoUrl = 'https://haki.id${rawLogo.startsWith('/') ? '' : '/'}$rawLogo';
      }
    }

    return TrademarkModel(
      id: id,
      mark: mark.isNotEmpty ? mark : 'Merek Tanpa Nama',
      applicant: applicant.isNotEmpty ? applicant : 'Pemilik Tidak Diketahui',
      registrationNumber: regNo.isNotEmpty ? regNo : '-',
      fillingNumber: fillNo.isNotEmpty ? fillNo : '-',
      fillingDate: fillDate.isNotEmpty ? fillDate : '-',
      registrationDate: regDate.isNotEmpty ? regDate : '-',
      expirationDate: expDate.isNotEmpty ? expDate : '-',
      niceClasses: classes,
      status: status.isNotEmpty ? status : 'Status Tidak Diketahui',
      logoUrl: fullLogoUrl,
      pdkiLink: link,
      applicantAddress: address.isNotEmpty ? address : '-',
      goodsServices: services,
    );
  }
}

/// Represents the search results from `https://haki.id/api/trademarks`.
class TrademarkSearchResult {
  const TrademarkSearchResult({
    required this.success,
    required this.total,
    required this.totalPages,
    required this.page,
    required this.items,
  });

  final bool success;
  final int total;
  final int totalPages;
  final int page;
  final List<TrademarkModel> items;

  bool get isEmpty => items.isEmpty;
}

