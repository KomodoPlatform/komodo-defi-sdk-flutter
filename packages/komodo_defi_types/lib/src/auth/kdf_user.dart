// TODO! Document this class
// wallet_id.dart
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Represents a unique wallet identifier
class WalletId extends Equatable {
  const WalletId({
    required this.name,
    this.pubkeyHash,
  });

  /// Creates a WalletId with just the name
  factory WalletId.fromName(String name) => WalletId(name: name);

  /// Creates a full WalletId with pubkey hash
  factory WalletId.withPubkeyHash(String name, String pubkeyHash) =>
      WalletId(name: name, pubkeyHash: pubkeyHash);

  /// Create from JSON representation
  factory WalletId.fromJson(JsonMap json) => WalletId(
        name: json.value<String>('name'),
        pubkeyHash: json.valueOrNull<String>('pubkey_hash'),
      );

  /// The wallet's name (always available)
  final String name;

  /// The wallet's pubkey hash (only available when authenticated)
  final String? pubkeyHash;

  /// Check if this wallet ID has full identification (pubkey hash)
  bool get hasFullIdentity => pubkeyHash != null;

  /// Returns the wallet ID as a compound string
  /// (name + pubkey hash if available)
  String get compoundId => pubkeyHash == null ? name : '$name:$pubkeyHash';

  bool isSameAs(WalletId other) =>
      name == other.name && pubkeyHash == other.pubkeyHash;

  @override
  List<Object?> get props => [name, pubkeyHash];

  /// Convert to JSON representation
  JsonMap toJson() => {
        'name': name,
        if (pubkeyHash != null) 'pubkey_hash': pubkeyHash,
      };
}

/// Updated KdfUser to use WalletId
class KdfUser extends Equatable {
  const KdfUser({
    required this.walletId,
    required this.authOptions,
    required this.isBip39Seed,
  });

  /// Create from JSON representation
  factory KdfUser.fromJson(JsonMap json) => KdfUser(
        walletId: WalletId.fromJson(json.value<JsonMap>('wallet_id')),
        authOptions: AuthOptions.fromJson(json.value<JsonMap>('auth_options')),
        isBip39Seed: json.value<bool>('is_bip39_seed'),
      );

  final WalletId walletId;
  final AuthOptions authOptions;
  final bool isBip39Seed;

  bool get isHd => authOptions.derivationMethod == DerivationMethod.hdWallet;

  // Update copyWith to include new field
  KdfUser copyWith({
    WalletId? walletId,
    AuthOptions? authOptions,
    bool? isBip39Seed,
  }) {
    return KdfUser(
      walletId: walletId ?? this.walletId,
      authOptions: authOptions ?? this.authOptions,
      isBip39Seed: isBip39Seed ?? this.isBip39Seed,
    );
  }

  @override
  List<Object?> get props => [walletId, authOptions, isBip39Seed];

  JsonMap toJson() => {
        'wallet_id': walletId.toJson(),
        'auth_options': authOptions.toJson(),
        'is_bip39_seed': isBip39Seed,
      };
}
