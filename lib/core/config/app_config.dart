import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Base URL configurable según plataforma de desarrollo.
class AppConfig {
  AppConfig._();

  /// Emulador Android → host de la máquina: 10.0.2.2
  /// iOS Simulator / Desktop / Web → localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5282';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5282';
    }
    return 'http://localhost:5282';
  }

  static const String apiPrefix = '/api';
}
