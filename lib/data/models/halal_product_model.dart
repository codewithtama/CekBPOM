/// Represents an officially certified Halal product from the BPJPH Kemenag database.
class HalalProductModel {
  const HalalProductModel({
    required this.id,
    required this.productName,
    required this.brandName,
    required this.producerName,
    required this.certificateNumber,
    required this.issueDate,
    required this.factoryName,
    required this.factoryLocation,
    required this.businessScale,
    required this.photoUrl,
  });

  final String id;
  final String productName;
  final String brandName;
  final String producerName;
  final String certificateNumber;
  final String issueDate;
  final String factoryName;
  final String factoryLocation;
  final String businessScale;
  final String photoUrl;

  /// Creates a [HalalProductModel] from raw JSON extracted from BPJPH.
  factory HalalProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final productName = (json['nama_produk'] as String? ?? '').trim();
    final brandName = (json['merek_dagang'] as String? ?? '').trim();

    final pelakuUsaha = json['pelaku_usaha'] as Map<String, dynamic>?;
    final producerName = (pelakuUsaha?['nama_pelaku_usaha'] as String? ?? '').trim();

    final sertifikat = json['sertifikat'] as Map<String, dynamic>?;
    final certificateNumber = (sertifikat?['no_sertifikat'] as String? ?? '').trim();
    final issueDate = (sertifikat?['tgl_terbit_sertifikat'] as String? ?? '').trim();

    final pabrikList = (json['pabrik'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    String factoryName = '';
    String factoryLocation = '';

    if (pabrikList.isNotEmpty) {
      final firstPabrik = pabrikList.first;
      factoryName = (firstPabrik['nama'] as String? ?? '').trim();
      final alamat = (firstPabrik['alamat'] as String? ?? '').trim();
      final kabKota = (firstPabrik['kab_kota'] as String? ?? '').trim();
      final provinsi = (firstPabrik['provinsi'] as String? ?? '').trim();

      final parts = <String>[
        if (alamat.isNotEmpty) alamat,
        if (kabKota.isNotEmpty) kabKota,
        if (provinsi.isNotEmpty) provinsi,
      ];
      factoryLocation = parts.join(', ');
    }

    final businessScale = (json['skala_usaha'] as String? ?? '').trim();
    final foto = (json['foto'] as String? ?? '').trim();

    return HalalProductModel(
      id: id,
      productName: productName.isNotEmpty ? productName : 'Nama Produk Tidak Diketahui',
      brandName: brandName.isNotEmpty ? brandName : '-',
      producerName: producerName.isNotEmpty ? producerName : 'Pelaku Usaha Tidak Diketahui',
      certificateNumber: certificateNumber.isNotEmpty ? certificateNumber : '-',
      issueDate: issueDate.isNotEmpty ? issueDate : '-',
      factoryName: factoryName.isNotEmpty ? factoryName : '-',
      factoryLocation: factoryLocation.isNotEmpty ? factoryLocation : '-',
      businessScale: businessScale,
      photoUrl: foto,
    );
  }
}

/// Represents the paginated result of a native Halal search query.
class HalalSearchResult {
  const HalalSearchResult({
    required this.items,
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
    required this.pageSize,
  });

  final List<HalalProductModel> items;
  final int currentPage;
  final int totalItems;
  final int totalPages;
  final int pageSize;

  bool get hasMore => currentPage < totalPages;
  bool get isEmpty => items.isEmpty;
}
