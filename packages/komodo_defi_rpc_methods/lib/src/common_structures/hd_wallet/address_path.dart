import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'address_path.freezed.dart';

/// Address path for HD wallet operations
///
/// Reference: https://komodoplatform.com/en/docs/komodo-defi-framework/api/common_structures/wallet/#address-path
///
/// The AddressPath can be specified in two ways:
/// 1. Using a full derivation path (e.g., "m/44'/141'/0'/0/0")
/// 2. Using component parts: account_id, chain, and address_id
@freezed
class AddressPath with _$AddressPath {
  /// Creates an AddressPath using a full derivation path
  ///
  /// Format: m/44'/COIN_ID'/ACCOUNT_ID'/CHAIN/ADDRESS_ID
  /// (or m/84'/COIN_ID'/ACCOUNT_ID'/CHAIN/ADDRESS_ID for segwit coins)
  ///
  /// Example: `AddressPath.derivationPath("m/44'/141'/1'/0/3")`
  const factory AddressPath.derivationPath(String path) = _DerivationPath;

  /// Creates an AddressPath using component parts
  ///
  /// [accountId] - The index of the account in the wallet, starting from 0
  /// [chain] - Either "External" or "Internal"
  /// [addressId] - The index of the address in the account, starting from 0
  ///
  /// Example:
  /// ```dart
  /// AddressPath.components(
  ///   accountId: 1,
  ///   chain: 'External',
  ///   addressId: 3,
  /// )
  /// ```
  const factory AddressPath.components({
    required int accountId,
    required String chain,
    required int addressId,
  }) = _ComponentsPath;

  const AddressPath._();

  /// Creates an AddressPath from JSON
  ///
  /// Supports both formats:
  /// - `{"derivation_path": "m/44'/141'/1'/0/3"}`
  /// - `{"account_id": 1, "chain": "External", "address_id": 3}`
  factory AddressPath.fromJson(JsonMap json) {
    final derivationPath = json.valueOrNull<String>('derivation_path');
    if (derivationPath != null) {
      return AddressPath.derivationPath(derivationPath);
    }

    final accountId = json.valueOrNull<int>('account_id');
    final chain = json.valueOrNull<String>('chain');
    final addressId = json.valueOrNull<int>('address_id');

    if (accountId != null && chain != null && addressId != null) {
      return AddressPath.components(
        accountId: accountId,
        chain: chain,
        addressId: addressId,
      );
    }

    throw ArgumentError(
      'Invalid AddressPath JSON: must contain either derivation_path or '
      'account_id/chain/address_id components',
    );
  }

  /// Converts the AddressPath to JSON
  ///
  /// Returns either:
  /// - `{"derivation_path": "m/44'/141'/1'/0/3"}`
  /// - `{"account_id": 1, "chain": "External", "address_id": 3}`
  JsonMap toJson() {
    return when(
      derivationPath: (path) => {'derivation_path': path},
      components: (accountId, chain, addressId) => {
        'account_id': accountId,
        'chain': chain,
        'address_id': addressId,
      },
    );
  }

  /// Whether this AddressPath uses a derivation path
  bool get usesDerivationPath =>
      maybeWhen(derivationPath: (_) => true, orElse: () => false);

  /// Whether this AddressPath uses component parts
  bool get usesComponents =>
      maybeWhen(components: (_, __, ___) => true, orElse: () => false);
}
