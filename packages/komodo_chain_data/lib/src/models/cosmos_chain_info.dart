import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_chain_data/src/models/chain_info.dart';
import 'package:komodo_chain_data/src/models/cosmos_api_endpoint.dart';
import 'package:komodo_chain_data/src/models/cosmos_asset.dart';
import 'package:komodo_chain_data/src/models/cosmos_best_apis.dart';
import 'package:komodo_chain_data/src/models/cosmos_explorer.dart';
import 'package:komodo_chain_data/src/models/cosmos_proxy_status.dart';
import 'package:komodo_chain_data/src/models/cosmos_versions.dart';

part 'cosmos_chain_info.freezed.dart';
part 'cosmos_chain_info.g.dart';

/// Cosmos-specific chain information from chains.cosmos.directory API.
///
/// This model represents a single chain entry from the chains array
/// in the chains.cosmos.directory API response.
@freezed
abstract class CosmosChainInfo with _$CosmosChainInfo implements ChainInfo {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CosmosChainInfo({
    required String name,
    required String path,
    required String chainName,
    required String networkType,
    required String prettyName,
    required String chainId,
    required String status,
    @JsonKey(name: 'bech32_prefix') required String bech32Prefix,
    required int slip44,
    required String symbol,
    required String display,
    required String denom,
    required int decimals,
    required CosmosBestApis bestApis,
    required CosmosProxyStatus proxyStatus,
    required CosmosVersions versions,
    String? image,
    String? website,
    int? height,
    List<CosmosExplorer>? explorers,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? params,
    List<CosmosAsset>? assets,
    List<String>? keywords,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? prices,
    String? coingeckoId,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, dynamic>? services,
  }) = _CosmosChainInfo;

  const CosmosChainInfo._();

  /// Creates a CosmosChainInfo from a JSON map (chains.cosmos.directory format).
  factory CosmosChainInfo.fromJson(Map<String, dynamic> json) =>
      _$CosmosChainInfoFromJson(json);

  /// Factory constructor for Cosmos Hub mainnet.
  factory CosmosChainInfo.cosmosHub() => const CosmosChainInfo(
    name: 'cosmoshub',
    path: 'cosmoshub',
    chainName: 'cosmoshub',
    networkType: 'mainnet',
    prettyName: 'Cosmos Hub',
    chainId: 'cosmoshub-4',
    status: 'live',
    bech32Prefix: 'cosmos',
    slip44: 118,
    symbol: 'ATOM',
    display: 'atom',
    denom: 'uatom',
    decimals: 6,
    bestApis: CosmosBestApis(
      rest: [CosmosApiEndpoint(address: 'https://cosmos-rest.publicnode.com')],
      rpc: [CosmosApiEndpoint(address: 'https://cosmos-rpc.publicnode.com')],
    ),
    proxyStatus: CosmosProxyStatus(rest: true, rpc: true),
    versions: CosmosVersions(
      applicationVersion: 'v21.0.0',
      cosmosSdkVersion: 'v0.50.10',
      tendermintVersion: '0.38.12',
    ),
  );

  /// Factory constructor for Osmosis mainnet.
  factory CosmosChainInfo.osmosis() => const CosmosChainInfo(
    name: 'osmosis',
    path: 'osmosis',
    chainName: 'osmosis',
    networkType: 'mainnet',
    prettyName: 'Osmosis',
    chainId: 'osmosis-1',
    status: 'live',
    bech32Prefix: 'osmo',
    slip44: 118,
    symbol: 'OSMO',
    display: 'osmo',
    denom: 'uosmo',
    decimals: 6,
    bestApis: CosmosBestApis(
      rest: [CosmosApiEndpoint(address: 'https://osmosis-api.polkachu.com')],
      rpc: [CosmosApiEndpoint(address: 'https://osmosis-rpc.polkachu.com')],
    ),
    proxyStatus: CosmosProxyStatus(rest: true, rpc: true),
    versions: CosmosVersions(
      applicationVersion: 'v28.0.0',
      cosmosSdkVersion: 'v0.50.10',
      tendermintVersion: '0.38.12',
    ),
  );

  /// Factory constructor for Juno mainnet.
  factory CosmosChainInfo.juno() => const CosmosChainInfo(
    name: 'juno',
    path: 'juno',
    chainName: 'juno',
    networkType: 'mainnet',
    prettyName: 'Juno',
    chainId: 'juno-1',
    status: 'live',
    bech32Prefix: 'juno',
    slip44: 118,
    symbol: 'JUNO',
    display: 'juno',
    denom: 'ujuno',
    decimals: 6,
    bestApis: CosmosBestApis(
      rest: [CosmosApiEndpoint(address: 'https://juno-api.polkachu.com')],
      rpc: [CosmosApiEndpoint(address: 'https://juno-rpc.polkachu.com')],
    ),
    proxyStatus: CosmosProxyStatus(rest: true, rpc: true),
    versions: CosmosVersions(
      applicationVersion: 'v23.0.0',
      cosmosSdkVersion: 'v0.47.16',
      tendermintVersion: '0.37.9',
    ),
  );

  /// Factory constructor for Akash Network mainnet.
  factory CosmosChainInfo.akash() => const CosmosChainInfo(
    name: 'akash',
    path: 'akash',
    chainName: 'akash',
    networkType: 'mainnet',
    prettyName: 'Akash',
    chainId: 'akashnet-2',
    status: 'live',
    bech32Prefix: 'akash',
    slip44: 118,
    symbol: 'AKT',
    display: 'akt',
    denom: 'uakt',
    decimals: 6,
    bestApis: CosmosBestApis(
      rest: [
        CosmosApiEndpoint(
          address: 'https://akash-mainnet-rest.cosmonautstakes.com/',
        ),
      ],
      rpc: [
        CosmosApiEndpoint(
          address: 'https://akash-mainnet-rpc.cosmonautstakes.com/',
        ),
      ],
    ),
    proxyStatus: CosmosProxyStatus(rest: true, rpc: true),
    versions: CosmosVersions(
      applicationVersion: 'v0.38.0',
      cosmosSdkVersion: 'v0.45.16',
      tendermintVersion: '0.34.27',
    ),
  );

  /// Factory constructor for Secret Network mainnet.
  factory CosmosChainInfo.secret() => const CosmosChainInfo(
    name: 'secretnetwork',
    path: 'secretnetwork',
    chainName: 'secretnetwork',
    networkType: 'mainnet',
    prettyName: 'Secret Network',
    chainId: 'secret-4',
    status: 'live',
    bech32Prefix: 'secret',
    slip44: 529,
    symbol: 'SCRT',
    display: 'scrt',
    denom: 'uscrt',
    decimals: 6,
    bestApis: CosmosBestApis(
      rest: [CosmosApiEndpoint(address: 'https://secret-api.polkachu.com')],
      rpc: [CosmosApiEndpoint(address: 'https://secret-rpc.polkachu.com')],
    ),
    proxyStatus: CosmosProxyStatus(rest: true, rpc: true),
    versions: CosmosVersions(
      applicationVersion: 'v1.15.0',
      cosmosSdkVersion: 'v0.45.16',
      tendermintVersion: '0.34.29',
    ),
  );

  /// Returns the WalletConnect format chain ID (cosmos:chainId).
  @override
  String get walletConnectChainId => 'cosmos:$chainId';

  /// Returns true if this is a testnet chain.
  @override
  bool get isTestnet {
    return networkType.toLowerCase() == 'testnet' ||
        name.toLowerCase().contains('test') ||
        chainId.contains('test');
  }

  /// Returns true if this is a mainnet chain.
  @override
  bool get isMainnet => !isTestnet;

  /// Returns the primary RPC endpoint if available.
  String? get primaryRpcEndpoint => bestApis.primaryRpcEndpoint;

  /// Returns the primary REST endpoint if available.
  String? get primaryRestEndpoint => bestApis.primaryRestEndpoint;

  /// Returns the native currency symbol (same as denom for Cosmos chains).
  String get nativeCurrency => denom;
}
