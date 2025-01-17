import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base class for protocol-specific exceptions
abstract class ProtocolException implements Exception {
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a protocol type is not supported
class UnsupportedProtocolException implements ProtocolException {
  UnsupportedProtocolException(this.message);
  @override
  final String message;
}

/// Thrown when required protocol fields are missing
class MissingProtocolFieldException implements ProtocolException {
  MissingProtocolFieldException(this.fieldName, this.fieldKey);
  final String fieldName;
  final String fieldKey;

  @override
  String get message => 'Missing required $fieldName field: $fieldKey';
}

/// Thrown when protocol parsing fails
class ProtocolParsingException implements ProtocolException {
  ProtocolParsingException(this.protocolType, this.details);
  final CoinSubClass protocolType;
  final String details;

  @override
  String get message =>
      'Failed to parse ${protocolType.formatted} protocol: $details';

  @override
  String toString() => '$runtimeType: $message';
}
