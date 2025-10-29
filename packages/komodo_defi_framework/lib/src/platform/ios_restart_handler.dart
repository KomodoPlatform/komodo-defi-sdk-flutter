import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Handles iOS app restart requests when KDF encounters fatal errors.
///
/// This class provides a way to trigger an iOS app restart by gracefully
/// exiting the app. The user will need to manually reopen the app.
///
/// This is a simple approach that works on iOS without requiring any
/// notification permissions or additional setup.
class IosRestartHandler {
  IosRestartHandler._();

  static final IosRestartHandler _instance = IosRestartHandler._();
  static IosRestartHandler get instance => _instance;

  static const MethodChannel _channel = MethodChannel(
    'com.komodoplatform.kdf/restart',
  );

  final Logger _logger = Logger('IosRestartHandler');

  /// Whether the platform supports app restart (iOS only)
  bool get isSupported => !kIsWeb && Platform.isIOS;

  /// Requests an app restart by gracefully exiting the app.
  ///
  /// The app will exit cleanly and the user will need to manually reopen it.
  ///
  /// [reason] is used for logging purposes to track why the restart was triggered.
  ///
  /// Returns `true` if the restart process was initiated successfully.
  /// Note: The app will exit shortly after this returns true.
  Future<bool> requestAppRestart({required String reason}) async {
    if (!isSupported) {
      _logger.warning(
        'iOS restart not supported on this platform (reason: $reason)',
      );
      return false;
    }

    _logger.severe('Requesting iOS app restart due to: $reason');

    try {
      final result = await _channel.invokeMethod<bool>(
        'requestAppRestart',
        <String, dynamic>{'reason': reason},
      );

      final success = result ?? false;
      if (success) {
        _logger.info('iOS app restart initiated successfully');
      } else {
        _logger.warning('iOS app restart request returned false');
      }

      return success;
    } on PlatformException catch (e) {
      _logger.severe('Failed to request app restart: ${e.message}', e);
      return false;
    } catch (e) {
      _logger.severe('Unexpected error requesting app restart', e);
      return false;
    }
  }

  /// Convenience method to request restart due to broken pipe error
  Future<bool> requestRestartForBrokenPipe() async {
    return requestAppRestart(reason: 'broken_pipe');
  }

  /// Convenience method to request restart due to shutdown signal
  Future<bool> requestRestartForShutdownSignal(String signalName) async {
    return requestAppRestart(reason: 'shutdown_signal_$signalName');
  }
}
