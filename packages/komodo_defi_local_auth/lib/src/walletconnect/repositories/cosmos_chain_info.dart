import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/repositories/chain_repository.dart';

part 'cosmos_chain_info.freezed.dart';
part 'cosmos_chain_info.g.dart';

/// Cosmos-specific chain information from chains.cosmos.directory.
@freezed
abstract class CosmosChainInfo with _$CosmosChainInfo implements ChainInfo {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosChainInfo({
    required String chainId,
    required String name,
    String? rpc,
    String? nativeCurrency,
    @JsonKey(name: 'bech32_prefix') String? bech32Prefix,
    List<String>? apis,
    String? prettyName,
    String? networkType,
    List<dynamic>? keyAlgos,
    int? slip44,
    Map<String, dynamic>? fees,
  }) = _CosmosChainInfo;

  const CosmosChainInfo._();

  /// Creates a CosmosChainInfo from a JSON map (chains.cosmos.directory format).
  factory CosmosChainInfo.fromJson(Map<String, dynamic> json) =>
      _$CosmosChainInfoFromJson(json);

  /// Factory constructor for Cosmos Hub mainnet.
  factory CosmosChainInfo.cosmosHub() => const CosmosChainInfo(
    chainId: 'cosmoshub-4',
    name: 'Cosmos Hub',
    prettyName: 'Cosmos Hub',
    networkType: 'mainnet',
    bech32Prefix: 'cosmos',
    rpc: 'https://cosmos-rpc.polkachu.com',
    nativeCurrency: 'uatom',
    slip44: 118,
  );

  /// Factory constructor for Osmosis mainnet.
  factory CosmosChainInfo.osmosis() => const CosmosChainInfo(
    chainId: 'osmosis-1',
    name: 'Osmosis',
    prettyName: 'Osmosis',
    networkType: 'mainnet',
    bech32Prefix: 'osmo',
    rpc: 'https://osmosis-rpc.polkachu.com',
    nativeCurrency: 'uosmo',
    slip44: 118,
  );

  /// Factory constructor for Juno mainnet.
  factory CosmosChainInfo.juno() => const CosmosChainInfo(
    chainId: 'juno-1',
    name: 'Juno',
    prettyName: 'Juno',
    networkType: 'mainnet',
    bech32Prefix: 'juno',
    rpc: 'https://juno-rpc.polkachu.com',
    nativeCurrency: 'ujuno',
    slip44: 118,
  );

  /// Factory constructor for Akash Network mainnet.
  factory CosmosChainInfo.akash() => const CosmosChainInfo(
    chainId: 'akashnet-2',
    name: 'Akash Network',
    prettyName: 'Akash',
    networkType: 'mainnet',
    bech32Prefix: 'akash',
    rpc: 'https://akash-rpc.polkachu.com',
    nativeCurrency: 'uakt',
    slip44: 118,
  );

  /// Factory constructor for Secret Network mainnet.
  factory CosmosChainInfo.secret() => const CosmosChainInfo(
    chainId: 'secret-4',
    name: 'Secret Network',
    prettyName: 'Secret Network',
    networkType: 'mainnet',
    bech32Prefix: 'secret',
    rpc: 'https://secret-rpc.polkachu.com',
    nativeCurrency: 'uscrt',
    slip44: 529,
  );

  /// Returns the WalletConnect format chain ID (cosmos:chainId).
  String get walletConnectChainId => 'cosmos:$chainId';

  /// Returns true if this is a testnet chain.
  bool get isTestnet {
    return networkType?.toLowerCase() == 'testnet' ||
        name.toLowerCase().contains('test') ||
        chainId.contains('test');
  }

  /// Returns true if this is a mainnet chain.
  bool get isMainnet => !isTestnet;
}
