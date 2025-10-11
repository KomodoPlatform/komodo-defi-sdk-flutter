import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/repositories/chain_repository.dart';

part 'evm_chain_info.freezed.dart';
part 'evm_chain_info.g.dart';

/// EVM-specific chain information from chainid.network.
@freezed
abstract class EvmChainInfo with _$EvmChainInfo implements ChainInfo {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EvmChainInfo({
    required String chainId,
    required String name,
    required int networkId,
    String? rpc,
    String? nativeCurrency,
    List<String>? explorers,
    String? shortName,
    String? chain,
    String? icon,
    @JsonKey(name: 'infoURL') String? infoURL,
  }) = _EvmChainInfo;

  const EvmChainInfo._();

  /// Creates an EvmChainInfo from a JSON map (chainid.network format).
  factory EvmChainInfo.fromJson(Map<String, dynamic> json) =>
      _$EvmChainInfoFromJson(json);

  /// Factory constructor for Ethereum mainnet.
  factory EvmChainInfo.ethereum() => const EvmChainInfo(
    chainId: '1',
    name: 'Ethereum Mainnet',
    networkId: 1,
    shortName: 'eth',
    chain: 'ETH',
    rpc: 'https://mainnet.infura.io/v3/',
    nativeCurrency: 'ETH',
    explorers: ['https://etherscan.io'],
    infoURL: 'https://ethereum.org',
  );

  /// Factory constructor for Polygon mainnet.
  factory EvmChainInfo.polygon() => const EvmChainInfo(
    chainId: '137',
    name: 'Polygon Mainnet',
    networkId: 137,
    shortName: 'matic',
    chain: 'Polygon',
    rpc: 'https://polygon-rpc.com/',
    nativeCurrency: 'MATIC',
    explorers: ['https://polygonscan.com'],
    infoURL: 'https://polygon.technology',
  );

  /// Factory constructor for BNB Smart Chain mainnet.
  factory EvmChainInfo.bnbSmartChain() => const EvmChainInfo(
    chainId: '56',
    name: 'BNB Smart Chain Mainnet',
    networkId: 56,
    shortName: 'bnb',
    chain: 'BSC',
    rpc: 'https://bsc-dataseed1.binance.org/',
    nativeCurrency: 'BNB',
    explorers: ['https://bscscan.com'],
    infoURL: 'https://www.bnbchain.org',
  );

  /// Factory constructor for Avalanche C-Chain mainnet.
  factory EvmChainInfo.avalanche() => const EvmChainInfo(
    chainId: '43114',
    name: 'Avalanche C-Chain',
    networkId: 43114,
    shortName: 'avax',
    chain: 'AVAX',
    rpc: 'https://api.avax.network/ext/bc/C/rpc',
    nativeCurrency: 'AVAX',
    explorers: ['https://snowtrace.io'],
    infoURL: 'https://www.avax.network',
  );

  /// Factory constructor for Fantom Opera mainnet.
  factory EvmChainInfo.fantom() => const EvmChainInfo(
    chainId: '250',
    name: 'Fantom Opera',
    networkId: 250,
    shortName: 'ftm',
    chain: 'FTM',
    rpc: 'https://rpc.ftm.tools/',
    nativeCurrency: 'FTM',
    explorers: ['https://ftmscan.com'],
    infoURL: 'https://fantom.foundation',
  );

  /// Returns the WalletConnect format chain ID (eip155:chainId).
  String get walletConnectChainId => 'eip155:$chainId';

  /// Returns true if this is a testnet chain.
  bool get isTestnet {
    final lowerName = name.toLowerCase();
    return lowerName.contains('test') ||
        lowerName.contains('goerli') ||
        lowerName.contains('sepolia') ||
        lowerName.contains('rinkeby') ||
        lowerName.contains('kovan') ||
        lowerName.contains('ropsten');
  }

  /// Returns true if this is a mainnet chain.
  bool get isMainnet => !isTestnet;
}
