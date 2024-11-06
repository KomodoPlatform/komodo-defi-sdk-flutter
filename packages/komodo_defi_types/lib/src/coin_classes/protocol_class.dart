import 'package:komodo_defi_types/src/utils/json_type_utils.dart';
import 'package:komodo_defi_types/types.dart';

/// Base class for all protocol definitions
abstract class ProtocolClass {
  const ProtocolClass({
    required this.subClass,
    required this.config,
  });

  final CoinSubClass subClass;
  final JsonMap config;

  /// Core protocol properties that all protocols must implement
  String? get derivationPath => config.valueOrNull<String>('derivation_path');
  bool get isTestnet => config.valueOrNull<bool>('is_testnet') ?? false;
  List<String>? get requiredServers;

  /// Factory to create the appropriate protocol class from JSON config
  static ProtocolClass fromJson(JsonMap json) {
    final subClass = CoinSubClass.tryParse(json.value<String>('type'));
    if (subClass == null) {
      throw UnsupportedProtocolException(
        'Could not determine protocol type from config',
      );
    }

    try {
      return switch (subClass) {
        CoinSubClass.utxo ||
        CoinSubClass.smartChain ||
        CoinSubClass.smartBch =>
          UtxoProtocol.fromJson(json),
        CoinSubClass.avx20 ||
        CoinSubClass.bep20 ||
        CoinSubClass.ftm20 ||
        CoinSubClass.matic ||
        CoinSubClass.hrc20 ||
        CoinSubClass.arbitrum ||
        CoinSubClass.erc20 =>
          Erc20Protocol.fromJson(json),
        CoinSubClass.slp => SlpProtocol.fromJson(json),
        CoinSubClass.qrc20 => QtumProtocol.fromJson(json),
        CoinSubClass.zhtlc => ZhtlcProtocol.fromJson(json),
        _ => throw UnsupportedProtocolException(
            'Unsupported protocol type: ${subClass.formatted}',
          ),
      };
    } catch (e) {
      throw ProtocolParsingException(subClass, e.toString());
    }
  }

  /// Convert protocol back to JSON representation
  JsonMap toJson() => config;
}
