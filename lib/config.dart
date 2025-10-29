import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class Config {
  static String? _baseUrl;

  static Future<String> get baseUrl async {
    if (_baseUrl != null) return _baseUrl!;

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      // 🌐 Running on web
      _baseUrl = "https://barangaydocument.bsitfoura.com";
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.isPhysicalDevice) {
        // 📱 Physical Android device → use hosted API
        _baseUrl = "https://barangaydocument.bsitfoura.com";
      } else {
        // 🧪 Android emulator → use local API
        _baseUrl = "https://barangaydocument.bsitfoura.com";
      }
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;

      if (iosInfo.isPhysicalDevice) {
        // 📱 Physical iPhone → use hosted API
        _baseUrl = "https://barangaydocument.bsitfoura.com";
      } else {
        // 🧪 iOS simulator → use localhost
        _baseUrl = "https://barangaydocument.bsitfoura.com";
      }
    } else {
      // 💻 Windows/Mac/Linux testing
      _baseUrl = "https://barangaydocument.bsitfoura.com";
    }

    return _baseUrl!;
  }
}
