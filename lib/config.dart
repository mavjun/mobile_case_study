// lib/config.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class Config {
  static String? _baseUrl;

  static Future<String> get baseUrl async {
    if (_baseUrl != null) return _baseUrl!;

    // ✅ If running on web, just return your LAN or hosted URL directly
    if (kIsWeb) {
      _baseUrl = "http://192.168.1.3/case_stud"; // <-- or your hosted URL later
      return _baseUrl!;
    }

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // ✅ Android emulator uses 10.0.2.2 to access host PC
      _baseUrl = "http://192.168.1.3/case_stud";
    } else if (Platform.isIOS) {
      // ✅ iOS simulator equivalent
      _baseUrl = "http://192.168.1.3/case_stud";
    } else {
      // ✅ Physical device on LAN or PC build
      _baseUrl = "http://192.168.1.3/case_stud"; // your LAN IP
    }

    return _baseUrl!;
  }
}
