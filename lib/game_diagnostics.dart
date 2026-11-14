import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';

/// Centralized, non-fatal diagnostics for unexpected framework and async errors.
class GameDiagnostics {
  GameDiagnostics._();

  static bool _installed = false;

  static void install() {
    if (_installed) return;
    _installed = true;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      record('flutter', details.exception, details.stack ?? StackTrace.current);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      record('uncaught', error, stackTrace);
      // Return false so the platform's default error handling is preserved.
      return false;
    };
  }

  static void record(String scope, Object error, StackTrace stackTrace) {
    debugPrint('[ArcheroFM][$scope] $error\n$stackTrace');
  }
}
