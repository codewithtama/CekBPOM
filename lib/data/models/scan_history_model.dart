import 'package:hive/hive.dart';
import 'product_model.dart';

part 'scan_history_model.g.dart';

@HiveType(typeId: 1)
class ScanHistoryModel extends HiveObject {
  @HiveField(0)
  final ProductModel product;

  @HiveField(1)
  final DateTime scanDate;

  ScanHistoryModel({
    required this.product,
    required this.scanDate,
  });
}
