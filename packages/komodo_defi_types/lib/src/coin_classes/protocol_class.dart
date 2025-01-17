import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';

/// Base class for all protocol definitions
abstract class ProtocolClass {
  const ProtocolClass({
    required this.subClass,
    required this.config,
    this.supportedProtocols = const [],
  });

  /// Creates the appropriate protocol class from JSON config
  factory ProtocolClass.fromJson(
    JsonMap json, {
    CoinSubClass? requestedType,
  }) {
    final primaryType =
        requestedType ?? CoinSubClass.parse(json.value<String>('type'));
    final otherTypes = json
            .valueOrNull<List<dynamic>>('other_types')
            ?.map(
              (type) => CoinSubClass.parse(type as String),
            )
            .toList() ??
        [];

    // If a specific type is requested, update the config
    final configToUse = requestedType != null && requestedType != primaryType
        ? (JsonMap.from(json)
          ..['type'] = requestedType.toString().split('.').last)
        : json;
    try {
      return switch (primaryType) {
        CoinSubClass.utxo || CoinSubClass.smartChain => UtxoProtocol.fromJson(
            configToUse,
            supportedProtocols: otherTypes,
          ),
        // SLP is no longer supported by its own protocol (BCH)
        // CoinSubClass.slp => SlpProtocol.fromJson(
        //     configToUse,
        //     supportedProtocols: otherTypes,
        //   ),
        CoinSubClass.avx20 ||
        CoinSubClass.bep20 ||
        CoinSubClass.ftm20 ||
        CoinSubClass.matic ||
        CoinSubClass.hrc20 ||
        CoinSubClass.arbitrum ||
        CoinSubClass.moonriver ||
        CoinSubClass.moonbeam ||
        CoinSubClass.ethereumClassic ||
        CoinSubClass.ubiq ||
        CoinSubClass.krc20 ||
        CoinSubClass.ewt ||
        CoinSubClass.hecoChain ||
        CoinSubClass.rskSmartBitcoin ||
        CoinSubClass.erc20 =>
          Erc20Protocol.fromJson(json),
        CoinSubClass.qrc20 => QtumProtocol.fromJson(json),
        CoinSubClass.zhtlc => ZhtlcProtocol.fromJson(json),
        CoinSubClass.tendermintToken ||
        CoinSubClass.tendermint =>
          TendermintProtocol.fromJson(
            configToUse,
            supportedProtocols: otherTypes,
          ),
        CoinSubClass.sia => SiaProtocol.fromJson(
            configToUse,
            supportedProtocols: otherTypes,
          ),
        CoinSubClass.slp ||
        CoinSubClass.smartBch ||
        CoinSubClass.unknown =>
          throw UnsupportedProtocolException(
            'Unsupported protocol type: ${primaryType.formatted}',
          ),
        // _ => throw UnsupportedProtocolException(
        //     'Unsupported protocol type: ${subClass.formatted}',
        //   ),
      };
    } catch (e) {
      throw ProtocolParsingException(primaryType, e.toString());
    }
  }

  final CoinSubClass subClass;
  final JsonMap config;
  final List<CoinSubClass> supportedProtocols;

  /// Whether this protocol supports multiple addresses per wallet
  bool get supportsMultipleAddresses;

  /// Whether this protocol requires HD wallet mode
  bool get requiresHdWallet;

  /// Core protocol properties that all protocols must implement
  String? get derivationPath => config.valueOrNull<String>('derivation_path');
  bool get isTestnet => config.valueOrNull<bool>('is_testnet') ?? false;
  ActivationRpcData get requiredServers => ActivationRpcData.fromJson(config);

  /// Convert protocol back to JSON representation
  JsonMap toJson() => {
        ...config,
        if (supportedProtocols.isNotEmpty)
          'other_types': supportedProtocols
              .map((p) => p.toString().split('.').last)
              .toList(),
      };

  /// Check if this protocol supports a given protocol type
  bool supportsProtocolType(CoinSubClass type) {
    return subClass == type || supportedProtocols.contains(type);
  }

  /// Creates an alternate protocol instance for a supported protocol type
  ProtocolClass? createProtocolVariant(CoinSubClass type) {
    if (!supportsProtocolType(type) || type == subClass) return null;

    final variantConfig = JsonMap.from(config)
      ..['type'] = type.toString().split('.').last;

    return ProtocolClass.fromJson(variantConfig);
  }

  ActivationParams defaultActivationParams() =>
      ActivationParams.fromConfigJson(config);
}
