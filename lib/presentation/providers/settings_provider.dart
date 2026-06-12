import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class AppSettings {
  final bool enableVibration;
  final bool enableSound;

  AppSettings({
    required this.enableVibration,
    required this.enableSound,
  });

  AppSettings copyWith({
    bool? enableVibration,
    bool? enableSound,
  }) {
    return AppSettings(
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _boxName = 'settings_box';
  
  SettingsNotifier() : super(AppSettings(enableVibration: true, enableSound: true)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      final vibe = box.get('enableVibration', defaultValue: true) as bool;
      final sound = box.get('enableSound', defaultValue: true) as bool;
      state = AppSettings(enableVibration: vibe, enableSound: sound);
    } catch (_) {
      // Fallback if Hive box fails to open
      state = AppSettings(enableVibration: true, enableSound: true);
    }
  }

  Future<void> toggleVibration(bool value) async {
    state = state.copyWith(enableVibration: value);
    try {
      final box = Hive.box(_boxName);
      await box.put('enableVibration', value);
    } catch (_) {
      final box = await Hive.openBox(_boxName);
      await box.put('enableVibration', value);
    }
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(enableSound: value);
    try {
      final box = Hive.box(_boxName);
      await box.put('enableSound', value);
    } catch (_) {
      final box = await Hive.openBox(_boxName);
      await box.put('enableSound', value);
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
