/// Enum representing Trezor device connection status
enum TrezorConnectionStatus {
  /// Device is connected and ready for operations
  connected,

  /// Device is disconnected
  disconnected,

  /// Device is busy with another operation
  busy,

  /// Device is unreachable (possibly hardware issue or driver problem)
  unreachable,

  /// Unknown status (for unrecognized status strings)
  unknown;

  /// Parse a string status from the API response into enum
  static TrezorConnectionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return TrezorConnectionStatus.connected;
      case 'disconnected':
        return TrezorConnectionStatus.disconnected;
      case 'busy':
        return TrezorConnectionStatus.busy;
      case 'unreachable':
        return TrezorConnectionStatus.unreachable;
      default:
        return TrezorConnectionStatus.unknown;
    }
  }

  /// Convert enum back to string representation
  String get value {
    switch (this) {
      case TrezorConnectionStatus.connected:
        return 'Connected';
      case TrezorConnectionStatus.disconnected:
        return 'Disconnected';
      case TrezorConnectionStatus.busy:
        return 'Busy';
      case TrezorConnectionStatus.unreachable:
        return 'Unreachable';
      case TrezorConnectionStatus.unknown:
        return 'Unknown';
    }
  }

  /// Check if the status indicates the device is available for operations
  bool get isAvailable => this == TrezorConnectionStatus.connected;

  /// Check if the status indicates the device is not available
  bool get isUnavailable =>
      this == TrezorConnectionStatus.disconnected ||
      this == TrezorConnectionStatus.unreachable;

  /// Check if the device should continue being monitored
  bool get shouldContinueMonitoring =>
      this != TrezorConnectionStatus.disconnected;
}
