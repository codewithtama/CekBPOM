import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String registrationNumber;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String brand;

  @HiveField(4)
  final String package;

  @HiveField(5)
  final String form;

  @HiveField(6)
  final String manufacturer;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String expiredDate;

  @HiveField(9)
  final String registeredDate;

  @HiveField(10)
  final String category;

  @HiveField(11)
  final String ingredients;

  @HiveField(12)
  final bool isFound;

  ProductModel({
    required this.productId,
    required this.registrationNumber,
    required this.name,
    required this.brand,
    required this.package,
    required this.form,
    required this.manufacturer,
    required this.status,
    required this.expiredDate,
    required this.registeredDate,
    required this.category,
    required this.ingredients,
    required this.isFound,
  });

  /// Factory constructor to parse data from BPOM `/produk-dt/all` DataTables POST JSON response
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['PRODUCT_ID'] ?? json['ID']?.toString() ?? '',
      registrationNumber: json['PRODUCT_REGISTER'] ?? '',
      name: json['PRODUCT_NAME'] ?? '',
      brand: json['PRODUCT_BRANDS'] ?? '-',
      package: json['PRODUCT_PACKAGE'] ?? '-',
      form: json['PRODUCT_FORM'] ?? '-',
      manufacturer: json['MANUFACTURER_NAME'] ?? json['REGISTRAR'] ?? '-',
      // BPOM status: 'Berlaku' or 'Aktif' means active/valid
      status: json['STATUS'] ?? '',
      expiredDate: json['PRODUCT_EXPIRED'] ?? '',
      registeredDate: json['PRODUCT_DATE'] ?? json['SUBMIT_DATE'] ?? '',
      category: json['CATEGORY'] ?? json['APPLICATION'] ?? '',
      ingredients: json['INGREDIENTS'] ?? '',
      isFound: true,
    );
  }

  /// Create a model representing a product not found in the BPOM database
  factory ProductModel.notFound(String code) {
    return ProductModel(
      productId: '',
      registrationNumber: code,
      name: 'Produk Tidak Terdaftar',
      brand: '-',
      package: '-',
      form: '-',
      manufacturer: '-',
      status: 'TIDAK TERDAFTAR',
      expiredDate: '',
      registeredDate: '',
      category: '-',
      ingredients: '',
      isFound: false,
    );
  }

  /// Helper to determine color status badge
  /// - GREEN (aman): status is 'berlaku' or 'aktif' AND not expired
  /// - YELLOW (expired / warning): status is 'berlaku' but expired, or other status
  /// - RED (bahaya / palsu): not found
  String get safetyStatus {
    if (!isFound) {
      return 'TIDAK TERDAFTAR';
    }
    
    // Check if expired
    if (expiredDate.isNotEmpty) {
      try {
        final expiry = DateTime.parse(expiredDate);
        if (expiry.isBefore(DateTime.now())) {
          return 'KEDALUWARSA';
        }
      } catch (_) {
        // Parse error, ignore
      }
    }
    
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'berlaku' || lowerStatus == 'aktif' || lowerStatus == 'telah disetujui') {
      return 'AMAN';
    }
    
    return 'PERLU DICEK';
  }
}
