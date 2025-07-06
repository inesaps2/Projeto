import 'package:flutter/foundation.dart';
import 'dart:io';

class Config {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:3000";
    } else {
      return "http://192.168.0.139:3000";
    }
  }
}



