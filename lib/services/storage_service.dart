import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service to manage SharedPreferencesAsync
/// Ensures only ONE instance exists throughout the app lifetime
class StorageService {
  static final StorageService _instance = StorageService._internal();
  late final SharedPreferencesAsync _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal() {
    _prefs = SharedPreferencesAsync();
  }

  /// Get the singleton instance of SharedPreferencesAsync
  SharedPreferencesAsync get prefs => _prefs;
}
