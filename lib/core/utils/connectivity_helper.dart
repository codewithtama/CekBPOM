import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  ConnectivityHelper._();

  static final Connectivity _connectivity = Connectivity();

  /// Returns true if the device has an active network connection (WiFi, Mobile, etc.)
  static Future<bool> isConnected() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      // If error occurs, assume we might be connected or let API request fail naturally
      return true;
    }
  }

  /// Stream to listen for connection changes
  static Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
