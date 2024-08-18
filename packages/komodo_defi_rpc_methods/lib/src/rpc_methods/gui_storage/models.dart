import 'package:komodo_defi_types/komodo_defi_types.dart';

class AccountId {
  // Constructor for `hw` type with a `device_pubkey`
  AccountId.hw({required this.devicePubkey})
      : type = 'hw',
        accountIdx = null;

  // Constructor for `iguana` type
  AccountId.iguana()
      : type = 'iguana',
        accountIdx = null,
        devicePubkey = null;

  // Constructor for `hd` type with an `account_idx`
  AccountId.hd({required this.accountIdx})
      : type = 'hd',
        devicePubkey = null;

  // Parse from JSON using the helper function
  factory AccountId.fromJson(Map<String, dynamic> json) {
    final type = json.value<String>('type');
    switch (type) {
      case 'iguana':
        return AccountId.iguana();
      case 'hd':
        return AccountId.hd(accountIdx: json.value<int>('account_idx'));
      case 'hw':
        return AccountId.hw(devicePubkey: json.value<String>('device_pubkey'));
      default:
        throw ArgumentError('Unknown account type: $type');
    }
  }
  final String type;
  final int? accountIdx;
  final String? devicePubkey;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (accountIdx != null) 'account_idx': accountIdx,
      if (devicePubkey != null) 'device_pubkey': devicePubkey,
    };
  }
}

class AccountInfo {
  AccountInfo({
    required this.accountId,
    required this.name,
    required this.description,
    required this.balanceUsd,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      accountId: AccountId.fromJson(json.value<JsonMap>('account_id')),
      name: json.value<String>('name'),
      description: json.value<String>('description'),
      balanceUsd: BigDecimal.fromJson(json.value<String>('balance_usd')),
    );
  }
  final AccountId accountId;
  final String name;
  final String description;
  final BigDecimal balanceUsd;

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId.toJson(),
      'name': name,
      'description': description,
      'balance_usd': balanceUsd.toJson(),
    };
  }
}

class BigDecimal {
  BigDecimal(this.value);

  factory BigDecimal.fromJson(String json) {
    return BigDecimal(json);
  }
  final String value;

  Map<String, dynamic> toJson() => {
        'value': value,
      };
}

class EnabledAccountId extends AccountId {
  // Constructor for `iguana` type
  EnabledAccountId.iguana() : super.iguana();

  // Constructor for `hd` type with an `account_idx`
  EnabledAccountId.hd({required int accountIdx})
      : super.hd(accountIdx: accountIdx);

  // Ensure that `hw` type is not allowed
  @override
  factory EnabledAccountId.fromJson(Map<String, dynamic> json) {
    final type = json.value<String>('type');
    switch (type) {
      case 'iguana':
        return EnabledAccountId.iguana();
      case 'hd':
        return EnabledAccountId.hd(accountIdx: json.value<int>('account_idx'));
      default:
        throw ArgumentError('Invalid account type for EnabledAccountId: $type');
    }
  }
}
