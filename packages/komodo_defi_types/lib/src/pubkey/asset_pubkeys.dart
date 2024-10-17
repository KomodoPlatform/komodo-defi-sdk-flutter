import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/types.dart';

class AssetPubkeys {
  AssetPubkeys({
    required this.assetId,
    required this.addresses,
    required this.usedAddressesCount,
    required this.availableAddressesCount,
    required this.syncStatus,
  });
  final AssetId assetId;
  final List<PubkeyInfo> addresses;
  final int usedAddressesCount;
  final int availableAddressesCount;
  final SyncStatus syncStatus;

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId.toJson(),
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'usedAddressesCount': usedAddressesCount,
      'availableAddressesCount': availableAddressesCount,
      'syncStatus': syncStatus.toString(),
    };
  }
}

class PubkeyInfo {
  PubkeyInfo({
    required this.address,
    required this.chain,
    required this.spendableBalance,
    required this.unspendableBalance,
    this.derivationPath,
  });
  final String address;
  final String? derivationPath;
  final String chain;
  final Decimal spendableBalance;
  final Decimal unspendableBalance;

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'derivationPath': derivationPath,
      'chain': chain,
      'spendableBalance': spendableBalance.toString(),
      'unspendableBalance': unspendableBalance.toString(),
    };
  }
}
