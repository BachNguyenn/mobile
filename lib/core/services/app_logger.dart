import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[WARN] $message${error == null ? '' : ': $error'}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${error == null ? '' : ': $error'}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
