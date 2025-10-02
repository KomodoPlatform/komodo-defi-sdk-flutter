import 'package:flutter/foundation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Address path for HD wallet operations
///
/// Reference: https://komodoplatform.com/en/docs/komodo-defi-framework/api/common_structures/wallet/#address-path
///
/// The AddressPath can be specified in two ways:
/// 1. Using a full derivation path (e.g., "m/44'/141'/0'/0/0")
/// 2. Using component parts: account_id, chain, and address_id
@immutable
class AddressPath {
  /// Creates an AddressPath using a full derivation path
  ///
  /// Example: `AddressPath.derivationPath("m/44'/141'/1'/0/3")`
  const AddressPath.derivationPath(String this.derivationPath)
    : accountId = null,
      chain = null,
      addressId = null;

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
  const AddressPath.components({
    required this.accountId,
    required this.chain,
    required this.addressId,
  }) : derivationPath = null;

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

  /// The full BIP44 derivation path
  ///
  /// Format: m/44'/COIN_ID'/ACCOUNT_ID'/CHAIN/ADDRESS_ID
  /// (or m/84'/COIN_ID'/ACCOUNT_ID'/CHAIN/ADDRESS_ID for segwit coins)
  ///
  /// Example: "m/44'/141'/0'/0/0"
  final String? derivationPath;

  /// The index of the account in the wallet, starting from 0
  final int? accountId;

  /// The chain: either "External" or "Internal"
  ///
  /// Expressed as an integer with External being 0 and Internal being 1
  final String? chain;

  /// The index of the address in the account, starting from 0
  final int? addressId;

  /// Converts the AddressPath to JSON
  ///
  /// Returns either:
  /// - `{"derivation_path": "m/44'/141'/1'/0/3"}`
  /// - `{"account_id": 1, "chain": "External", "address_id": 3}`
  JsonMap toJson() {
    if (derivationPath != null) {
      return {'derivation_path': derivationPath};
    }

    return {'account_id': accountId, 'chain': chain, 'address_id': addressId};
  }

  /// Whether this AddressPath uses a derivation path
  bool get usesDerivationPath => derivationPath != null;

  /// Whether this AddressPath uses component parts
  bool get usesComponents => accountId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddressPath &&
        other.derivationPath == derivationPath &&
        other.accountId == accountId &&
        other.chain == chain &&
        other.addressId == addressId;
  }

  @override
  int get hashCode {
    return derivationPath.hashCode ^
        accountId.hashCode ^
        chain.hashCode ^
        addressId.hashCode;
  }

  @override
  String toString() {
    if (usesDerivationPath) {
      return 'AddressPath.derivationPath($derivationPath)';
    }
    return 'AddressPath.components('
        'accountId: $accountId, chain: $chain, addressId: $addressId)';
  }
}
