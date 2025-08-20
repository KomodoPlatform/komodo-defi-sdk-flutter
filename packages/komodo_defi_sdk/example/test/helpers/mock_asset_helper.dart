import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Helper utilities for creating mock assets in tests
class MockAssetHelper {
  /// Creates a mock UTXO asset with the given symbol
  static Asset createMockUtxoAsset({
    required String symbol,
    String? name,
  }) {
    return Asset(
      id: AssetId(
        id: symbol,
        name: name ?? symbol,
        symbol: AssetSymbol(assetConfigId: symbol),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      ),
      protocol: UtxoProtocol.fromJson({
        'type': 'UTXO',
        'coin': symbol,
        'is_testnet': false,
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'mm2': 1,
      }),
      isWalletOnly: false,
      signMessagePrefix: null,
    );
  }

  /// Creates a mock ERC20 asset with the given symbol
  static Asset createMockErc20Asset({
    required String symbol,
    String? name,
    int chainId = 1,
  }) {
    return Asset(
      id: AssetId(
        id: symbol,
        name: name ?? symbol,
        symbol: AssetSymbol(assetConfigId: symbol),
        chainId: AssetChainId(chainId: chainId),
        derivationPath: null,
        subClass: CoinSubClass.erc20,
      ),
      protocol: Erc20Protocol.fromJson({
        'type': 'ERC20',
        'coin': symbol,
        'is_testnet': false,
        'protocol': {
          'type': 'ERC20',
        },
      }),
      isWalletOnly: false,
      signMessagePrefix: null,
    );
  }

  /// Creates a mock asset with custom parameters
  static Asset createMockAsset({
    required String symbol,
    String? name,
    CoinSubClass subClass = CoinSubClass.utxo,
    int chainId = 0,
    bool isWalletOnly = false,
    String? signMessagePrefix,
  }) {
    final assetId = AssetId(
      id: symbol,
      name: name ?? symbol,
      symbol: AssetSymbol(assetConfigId: symbol),
      chainId: AssetChainId(chainId: chainId),
      derivationPath: null,
      subClass: subClass,
    );

    ProtocolClass protocol;
    switch (subClass) {
      case CoinSubClass.erc20:
      case CoinSubClass.bep20:
      case CoinSubClass.matic:
      case CoinSubClass.arbitrum:
      case CoinSubClass.avx20:
      case CoinSubClass.ftm20:
      case CoinSubClass.hrc20:
      case CoinSubClass.moonriver:
      case CoinSubClass.moonbeam:
      case CoinSubClass.ethereumClassic:
      case CoinSubClass.ubiq:
      case CoinSubClass.krc20:
      case CoinSubClass.ewt:
      case CoinSubClass.hecoChain:
      case CoinSubClass.rskSmartBitcoin:
        protocol = Erc20Protocol.fromJson({
          'type': subClass.formatted,
          'coin': symbol,
          'is_testnet': false,
          'protocol': {
            'type': 'ERC20',
          },
        });
        break;
      case CoinSubClass.tendermint:
      case CoinSubClass.tendermintToken:
        protocol = TendermintProtocol.fromJson({
          'type': subClass.formatted,
          'coin': symbol,
          'is_testnet': false,
          'protocol': {
            'type': 'TENDERMINT',
            'protocol_data': {
              'account_prefix': 'cosmos',
              'chain_id': 'cosmoshub-4',
              'chain_registry_name': 'cosmos',
            },
          },
        });
        break;
      case CoinSubClass.qrc20:
        protocol = QtumProtocol.fromJson({
          'type': 'QRC20',
          'coin': symbol,
          'is_testnet': false,
          'protocol': {
            'type': 'QRC20',
          },
        });
        break;
      case CoinSubClass.sia:
        protocol = SiaProtocol.fromJson({
          'type': 'SIA',
          'coin': symbol,
          'is_testnet': false,
        });
        break;
      case CoinSubClass.zhtlc:
        protocol = ZhtlcProtocol.fromJson({
          'type': 'ZHTLC',
          'coin': symbol,
          'is_testnet': false,
        });
        break;
      case CoinSubClass.utxo:
      case CoinSubClass.smartChain:
      case CoinSubClass.smartBch:
      default:
        protocol = UtxoProtocol.fromJson({
          'type': subClass == CoinSubClass.smartChain ? 'SMART_CHAIN' : 'UTXO',
          'coin': symbol,
          'is_testnet': false,
          'pubtype': 60,
          'p2shtype': 85,
          'wiftype': 188,
          'mm2': 1,
        });
        break;
    }

    return Asset(
      id: assetId,
      protocol: protocol,
      isWalletOnly: isWalletOnly,
      signMessagePrefix: signMessagePrefix,
    );
  }

  /// Commonly used mock assets for testing
  static final Asset mockKMD = createMockUtxoAsset(symbol: 'KMD', name: 'Komodo');
  static final Asset mockBTC = createMockUtxoAsset(symbol: 'BTC', name: 'Bitcoin');
  static final Asset mockLTC = createMockUtxoAsset(symbol: 'LTC', name: 'Litecoin');
  static final Asset mockDOGE = createMockUtxoAsset(symbol: 'DOGE', name: 'Dogecoin');
  static final Asset mockRFOX = createMockUtxoAsset(symbol: 'RFOX', name: 'RedFox Labs');

  static final Asset mockETH = createMockErc20Asset(symbol: 'ETH', name: 'Ethereum');
  static final Asset mockUSDT = createMockErc20Asset(symbol: 'USDT', name: 'Tether');
}
