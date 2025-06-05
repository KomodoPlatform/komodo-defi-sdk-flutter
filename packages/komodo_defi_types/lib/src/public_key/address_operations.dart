import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Result of address validation
class AddressValidation {
  const AddressValidation({
    required this.isValid,
    required this.address,
    required this.asset,
    this.invalidReason,
  });

  /// Whether the address is valid
  final bool isValid;

  /// The address that was validated
  final String address;

  /// The asset the address was validated for
  final Asset asset;

  /// Reason for invalidity if address is invalid
  final String? invalidReason;
}

/// Result of address conversion
class AddressConversionResult {
  const AddressConversionResult({
    required this.originalAddress,
    required this.convertedAddress,
    this.format,
    this.asset,
    this.sourceAsset,
    this.targetAsset,
  });

  /// The original input address
  final String originalAddress;

  /// The converted output address
  final String convertedAddress;

  /// The format converted to (for format conversions)
  final AddressFormat? format;

  /// The asset involved (for format conversions)
  final Asset? asset;

  /// Source asset (for UTXO conversions)
  final Asset? sourceAsset;

  /// Target asset (for UTXO conversions)
  final Asset? targetAsset;
}

/// Exception thrown when address conversion fails
class AddressConversionException implements Exception {
  AddressConversionException(
    this.message, {
    required this.address,
    required this.asset,
    this.targetFormat,
    this.targetAsset,
  });

  final String message;
  final String address;
  final Asset asset;
  final AddressFormat? targetFormat;
  final Asset? targetAsset;

  @override
  String toString() => message;
}
