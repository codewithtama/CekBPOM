import 'dart:developer' as developer;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../models/scan_history_model.dart';

class HistoryService {
  static const String boxName = 'scan_history';
  static const String paoBoxName = 'pao_records';

  /// Initializes Hive and registers adapters
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ScanHistoryModelAdapter());
      }
      
      await Hive.openBox<ScanHistoryModel>(boxName);
      await Hive.openBox<Map>(paoBoxName);
      developer.log('Hive Scan History and PAO records initialized successfully', name: 'HistoryService');
    } catch (e) {
      developer.log('Error initializing Hive', name: 'HistoryService', error: e);
    }
  }

  Box<ScanHistoryModel> get _box => Hive.box<ScanHistoryModel>(boxName);
  Box<Map> get _paoBox => Hive.box<Map>(paoBoxName);

  /// Retrieves all scan history sorted by date (latest first)
  List<ScanHistoryModel> getHistory() {
    try {
      final list = _box.values.toList();
      list.sort((a, b) => b.scanDate.compareTo(a.scanDate));
      return list;
    } catch (e) {
      developer.log('Error reading scan history from Hive', name: 'HistoryService', error: e);
      return [];
    }
  }

  /// Adds a new product to scan history
  Future<void> addHistory(ProductModel product) async {
    try {
      // Avoid duplication: if product registration already exists, remove old entry
      final existingKey = _box.values.firstWhere(
        (element) => element.product.registrationNumber == product.registrationNumber,
        orElse: () => ScanHistoryModel(
          product: product,
          scanDate: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      
      if (existingKey.scanDate.millisecondsSinceEpoch != 0) {
        await existingKey.delete();
      }

      final newRecord = ScanHistoryModel(
        product: product,
        scanDate: DateTime.now(),
      );
      await _box.add(newRecord);
      developer.log('Added scan history: ${product.name}', name: 'HistoryService');
    } catch (e) {
      developer.log('Error adding scan history to Hive', name: 'HistoryService', error: e);
    }
  }

  /// Deletes a specific history item by key
  Future<void> deleteHistoryItem(dynamic key) async {
    try {
      final record = _box.get(key);
      if (record != null) {
        await deletePao(record.product.registrationNumber);
      }
      await _box.delete(key);
      developer.log('Deleted scan history item with key: $key', name: 'HistoryService');
    } catch (e) {
      developer.log('Error deleting scan history item', name: 'HistoryService', error: e);
    }
  }

  /// Deletes all history items
  Future<void> clearHistory() async {
    try {
      await _box.clear();
      await clearAllPao();
      developer.log('Cleared all scan history and PAO records', name: 'HistoryService');
    } catch (e) {
      developer.log('Error clearing scan history', name: 'HistoryService', error: e);
    }
  }

  /// Checks if product with the registration number is cached in history (Offline fallback query)
  ProductModel? getCachedProduct(String code) {
    try {
      final cleanedCode = code.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      
      final records = _box.values.where((element) {
        final regNo = element.product.registrationNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();
        return regNo == cleanedCode;
      }).toList();

      if (records.isNotEmpty) {
        // Sort to get latest
        records.sort((a, b) => b.scanDate.compareTo(a.scanDate));
        developer.log('Found cached product for code: $code', name: 'HistoryService');
        return records.first.product;
      }
    } catch (e) {
      developer.log('Error querying cache', name: 'HistoryService', error: e);
    }
    return null;
  }

  /// Saves or updates PAO details for a product
  Future<void> savePao(String regNumber, DateTime openedDate, int paoMonths) async {
    try {
      final key = regNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      await _paoBox.put(key, {
        'openedDate': openedDate.toIso8601String(),
        'paoMonths': paoMonths,
      });
      developer.log('Saved PAO for product: $key', name: 'HistoryService');
    } catch (e) {
      developer.log('Error saving PAO', name: 'HistoryService', error: e);
    }
  }

  /// Retrieves PAO details for a product
  Map<dynamic, dynamic>? getPao(String regNumber) {
    try {
      final key = regNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      return _paoBox.get(key);
    } catch (e) {
      developer.log('Error reading PAO', name: 'HistoryService', error: e);
      return null;
    }
  }

  /// Deletes PAO details for a product
  Future<void> deletePao(String regNumber) async {
    try {
      final key = regNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      await _paoBox.delete(key);
      developer.log('Deleted PAO for product: $key', name: 'HistoryService');
    } catch (e) {
      developer.log('Error deleting PAO', name: 'HistoryService', error: e);
    }
  }

  /// Clears all PAO details
  Future<void> clearAllPao() async {
    try {
      await _paoBox.clear();
      developer.log('Cleared all PAO records', name: 'HistoryService');
    } catch (e) {
      developer.log('Error clearing PAO records', name: 'HistoryService', error: e);
    }
  }
}
