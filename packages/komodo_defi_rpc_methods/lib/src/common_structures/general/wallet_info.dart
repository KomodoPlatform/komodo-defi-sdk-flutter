import 'package:komodo_defi_types/komodo_defi_types.dart';

class WalletInfo {
  WalletInfo({
    required this.address,
    required this.type,
    required this.derivationMethod,
    required this.pubkey,
    this.miningPubkey,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      address: json.value<String>('address'),
      type: json.value<String>('type'),
      derivationMethod:
          Map<String, String>.from(json.value('derivation_method')),
      pubkey: json.value<String>('pubkey'),
      miningPubkey: json.value<String?>('mining_pubkey'),
    );
  }
  final String address;
  final String type;
  final Map<String, String> derivationMethod;
  final String pubkey;
  final String? miningPubkey;

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'type': type,
      'derivation_method': derivationMethod,
      'pubkey': pubkey,
      if (miningPubkey != null) 'mining_pubkey': miningPubkey,
    };
  }
}
