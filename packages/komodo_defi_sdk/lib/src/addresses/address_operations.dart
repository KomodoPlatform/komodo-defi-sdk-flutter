import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Provides operations for address validation and format conversion
class AddressOperations {
  AddressOperations(this._client);

  final ApiClient _client;

  /// Validates whether an address is valid for a given asset
  ///
  /// Returns [AddressValidation] containing validation result and any error details
  Future<AddressValidation> validateAddress({
    required Asset asset,
    required String address,
  }) async {
    try {
      final response = await _client.rpc.address.validateAddress(
        coin: asset.id.id,
        address: address,
      );

      return AddressValidation(
        isValid: response.isValid,
        invalidReason: response.reason,
        address: address,
        asset: asset,
      );
    } catch (e) {
      return AddressValidation(
        isValid: false,
        invalidReason: 'Validation failed: $e',
        address: address,
        asset: asset,
      );
    }
  }

  /// Converts an address to a specified format
  ///
  /// For example, convert BCH address between legacy and CashAddr formats
  Future<AddressConversionResult> convertFormat({
    required Asset asset,
    required String address,
    required AddressFormat format,
  }) async {
    try {
      final response = await _client.rpc.address.convertAddress(
        coin: asset.id.id,
        from: address,
        toFormat: format,
      );

      return AddressConversionResult(
        originalAddress: address,
        convertedAddress: response.address,
        format: format,
        asset: asset,
      );
    } catch (e) {
      throw AddressConversionException(
        'Failed to convert address format: $e',
        address: address,
        asset: asset,
        targetFormat: format,
      );
    }
  }

  /// Converts a UTXO address from one coin to another
  ///
  /// Use this to convert addresses between different UTXO chains (e.g., BTC to RVN)
  Future<AddressConversionResult> convertUtxoAddress({
    required Asset fromAsset,
    required Asset toAsset,
    required String address,
  }) async {
    if (fromAsset.protocol is! UtxoProtocol) {
      throw AddressConversionException(
        'Source asset must be UTXO-based',
        address: address,
        asset: fromAsset,
      );
    }

    if (toAsset.protocol is! UtxoProtocol) {
      throw AddressConversionException(
        'Target asset must be UTXO-based',
        address: address,
        asset: toAsset,
      );
    }

    try {
      final response = await _client.rpc.address.convertUtxoAddress(
        coin: fromAsset.id.id,
        address: address,
        toCoin: toAsset.id.id,
      );

      return AddressConversionResult(
        originalAddress: address,
        convertedAddress: response.result,
        sourceAsset: fromAsset,
        targetAsset: toAsset,
      );
    } catch (e) {
      throw AddressConversionException(
        'Failed to convert UTXO address: $e',
        address: address,
        asset: fromAsset,
        targetAsset: toAsset,
      );
    }
  }
}

/// Extension for standard format conversions
extension AddressFormatExtension on AddressOperations {
  /// Convenient method to convert BCH address to CashAddr format
  Future<AddressConversionResult> convertToCashAddr(
    String address,
    Asset asset, {
    String network = 'bitcoincash',
  }) {
    return convertFormat(
      asset: asset,
      address: address,
      format: AddressFormat(
        format: 'cashaddress',
        network: network,
      ),
    );
  }

  /// Convenient method to convert BCH address to legacy format
  Future<AddressConversionResult> convertToLegacy(
    String address,
    Asset asset,
  ) {
    return convertFormat(
      asset: asset,
      address: address,
      format: const AddressFormat(
        format: 'standard',
        network: '',
      ),
    );
  }
}

/// Extension for common UTXO conversions
extension UtxoAddressExtension on AddressOperations {
  /// Convert BTC address to RVN address format
  Future<AddressConversionResult> convertBtcToRvn(
    String btcAddress, {
    required Asset btc,
    required Asset rvn,
  }) {
    return convertUtxoAddress(
      fromAsset: btc,
      toAsset: rvn,
      address: btcAddress,
    );
  }
}

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
