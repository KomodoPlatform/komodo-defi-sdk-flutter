// TODO! Document this class
// wallet_id.dart
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Represents a unique wallet identifier
class WalletId extends Equatable {
  const WalletId({
    required this.name,
    required this.authOptions,
    this.pubkeyHash,
  });

  /// Creates a WalletId with just the name
  factory WalletId.fromName(String name, AuthOptions authOptions) =>
      WalletId(name: name, authOptions: authOptions);

  /// Creates a full WalletId with pubkey hash
  factory WalletId.withPubkeyHash(
    String name,
    AuthOptions authOptions,
    String pubkeyHash,
  ) => WalletId(name: name, pubkeyHash: pubkeyHash, authOptions: authOptions);

  /// Create from JSON representation
  factory WalletId.fromJson(JsonMap json) => WalletId(
    name: json.value<String>('name'),
    pubkeyHash: json.valueOrNull<String>('pubkey_hash'),
    authOptions: AuthOptions.fromJson(json.value<JsonMap>('auth_options')),
  );

  /// The wallet's name (always available)
  final String name;

  /// The wallet's pubkey hash (only available when authenticated)
  final String? pubkeyHash;

  /// The authentication options used to create this wallet (e.g. HD or iguana)
  final AuthOptions authOptions;

  /// Check if this wallet ID has full identification (pubkey hash)
  bool get hasFullIdentity => pubkeyHash != null;

  /// Returns the wallet ID as a compound string
  /// (name + pubkey hash if available)
  String get compoundId => pubkeyHash == null ? name : '$name:$pubkeyHash';

  bool get isHd => authOptions.derivationMethod == DerivationMethod.hdWallet;

  bool isSameAs(WalletId other) =>
      name == other.name && pubkeyHash == other.pubkeyHash;

  @override
  List<Object?> get props => [name, authOptions, pubkeyHash];

  /// Convert to JSON representation
  JsonMap toJson() => {
    'name': name,
    'auth_options': authOptions.toJson(),
    if (pubkeyHash != null) 'pubkey_hash': pubkeyHash,
  };

  WalletId copyWith({
    String? name,
    String? pubkeyHash,
    AuthOptions? authOptions,
  }) => WalletId(
    name: name ?? this.name,
    pubkeyHash: pubkeyHash ?? this.pubkeyHash,
    authOptions: authOptions ?? this.authOptions,
  );
}

/// Updated KdfUser to use WalletId
class KdfUser extends Equatable {
  const KdfUser({
    required this.walletId,
    required this.isBip39Seed,
    this.metadata = const {},
  });

  /// Create from JSON representation
  factory KdfUser.fromJson(JsonMap json) {
    final walletIdJson = json.value<JsonMap>('wallet_id');
    // Backwards compatibility for old format. This can be removed in the
    // following release because it was not public.
    final maybeAuthOptions = json.valueOrNull<JsonMap>('auth_options');
    if (maybeAuthOptions != null && !walletIdJson.containsKey('auth_options')) {
      walletIdJson['auth_options'] = maybeAuthOptions;
    }
    return KdfUser(
      walletId: WalletId.fromJson(walletIdJson),
      isBip39Seed: json.value<bool>('is_bip39_seed'),
      metadata: json.valueOrNull<JsonMap>('metadata') ?? const {},
    );
  }

  final WalletId walletId;
  final bool isBip39Seed;
  final JsonMap metadata;

  bool get isHd => walletId.isHd;

  @Deprecated(
    'Use walletId or isHd instead. This is only here for '
    'backwards compatibility.',
  )
  AuthOptions get authOptions => walletId.authOptions;

  // Update copyWith to include new field
  KdfUser copyWith({WalletId? walletId, bool? isBip39Seed, JsonMap? metadata}) {
    return KdfUser(
      walletId: walletId ?? this.walletId,
      isBip39Seed: isBip39Seed ?? this.isBip39Seed,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [walletId, isBip39Seed, metadata];

  JsonMap toJson() => {
    'wallet_id': walletId.toJson(),
    'is_bip39_seed': isBip39Seed,
    if (metadata.isNotEmpty) 'metadata': metadata,
  };
}
