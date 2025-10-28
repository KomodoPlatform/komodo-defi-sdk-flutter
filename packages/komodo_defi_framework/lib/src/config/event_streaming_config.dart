import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Configuration for KDF event streaming
///
/// This configuration enables Server-Sent Events (SSE) streaming from KDF.
/// See: https://komodoplatform.com/en/docs/komodo-defi-framework/setup/configure-mm2-json/
class EventStreamingConfiguration {
  const EventStreamingConfiguration({
    this.accessControlAllowOrigin = '*',
    this.workerPath,
  });

  /// Create from JSON
  factory EventStreamingConfiguration.fromJson(JsonMap json) {
    return EventStreamingConfiguration(
      accessControlAllowOrigin:
          json['access_control_allow_origin'] as String? ?? '*',
      workerPath: json['worker_path'] as String?,
    );
  }

  /// CORS access control header value
  /// Defaults to '*' to allow all origins
  final String accessControlAllowOrigin;

  /// Path to the worker script (primarily for web platforms)
  /// Optional, defaults to null
  final String? workerPath;

  /// Default configuration with permissive CORS
  static const EventStreamingConfiguration defaultConfig =
      EventStreamingConfiguration();

  /// Convert to JSON format for KDF startup configuration
  JsonMap toJson() => {
    'access_control_allow_origin': accessControlAllowOrigin,
    if (workerPath != null) 'worker_path': workerPath,
  };
}
