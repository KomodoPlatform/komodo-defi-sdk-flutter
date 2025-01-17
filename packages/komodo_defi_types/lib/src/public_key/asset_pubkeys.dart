import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetPubkeys {
  const AssetPubkeys({
    required this.assetId,
    required this.keys,
    // required this.usedAddressesCount,
    required this.availableAddressesCount,
    required this.syncStatus,
  });
  final AssetId assetId;
  final List<PubkeyInfo> keys;
  // final int usedAddressesCount;
  final int availableAddressesCount;
  final SyncStatusEnum syncStatus;

  Balance get balance =>
      keys.fold(Balance.zero(), (prev, element) => prev + element.balance);

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId.toJson(),
      'addresses': keys.map((e) => e.toJson()).toList(),
      // 'usedAddressesCount': usedAddressesCount,
      'availableAddressesCount': availableAddressesCount,
      'syncStatus': syncStatus.toString(),
    };
  }
}

/// Public type for the pubkeys info. Note that this is a separate type from the
/// on in the RPC library even though they are similar because we want to keep
/// the GUI types independent from the API types.

class PubkeyInfo extends NewAddressInfo {
  PubkeyInfo({
    required super.address,
    required super.derivationPath,
    required super.chain,
    required super.balance,
  });

  // The coin is active for swap if it is non-HD or if it is HD and is the
  // first address index. e.g. "m/44'/141'/0'/0/0", where the last 0 is the
  // address index.
  // NB: The intention is to add multi-address swap support in the future
  // either as an abstraction in the SDK or as a feature in the API. For the
  // former, the swap address will be locked to a single address when the
  // asset has ongoing swaps.
  bool get isActiveForSwap =>
      derivationPath == null || derivationPath!.endsWith('/0');
}

typedef Balance = BalanceInfo;

// class PubkeyInfo {
//   PubkeyInfo({
//     required this.address,
//     required this.chain,
//     required this.spendableBalance,
//     required this.unspendableBalance,
//     this.derivationPath,
//   });
//   final String address;
//   final String? derivationPath;
//   final String chain;
//   final Decimal spendableBalance;
//   final Decimal unspendableBalance;

//   Map<String, dynamic> toJson() {
//     return {
//       'address': address,
//       'derivationPath': derivationPath,
//       'chain': chain,
//       'spendableBalance': spendableBalance.toString(),
//       'unspendableBalance': unspendableBalance.toString(),
//     };
//   }
// }
