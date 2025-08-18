import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ZhtlcProtocol extends ProtocolClass {
  ZhtlcProtocol._({
    required super.subClass,
    required super.config,
  });

  factory ZhtlcProtocol.fromJson(JsonMap json) {
    _validateZhtlcConfig(json);
    return ZhtlcProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
    );
  }

  @override
  bool get supportsMultipleAddresses => false;

  @override
  bool get requiresHdWallet => false;

  static void _validateZhtlcConfig(JsonMap json) {
    final requiredFields = {
      // ZHTLC can operate in Light mode using lightwalletd and optionally electrum servers.
      // We require at least one of electrum servers or light wallet d servers to be present.
      // NOTE: We cannot assert both keys here due to varying network setups.
      // Validation occurs below.
    };

    // Backward compatibility: some configs provided 'electrum' under config used by Electrum mode
    final hasElectrum = json.containsKey('electrum');
    final hasLightWalletD = json.containsKey('light_wallet_d_servers');

    if (!hasElectrum && !hasLightWalletD) {
      throw MissingProtocolFieldException(
        'Electrum or LightwalletD servers',
        'electrum | light_wallet_d_servers',
      );
    }
  }

  String get zcashParamsPath =>
      config.valueOrNull<String>('zcash_params_path') ?? '';
}
