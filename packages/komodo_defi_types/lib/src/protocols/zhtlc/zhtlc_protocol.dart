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
      // 'zcash_params_path': 'Zcash parameters path',
      'electrum': 'Electrum servers',
    };

    for (final field in requiredFields.entries) {
      if (!json.containsKey(field.key)) {
        throw MissingProtocolFieldException(
          field.value,
          field.key,
        );
      }
    }
  }

  String get zcashParamsPath =>

      //TODO! config.value<String>('zcash_params_path');
      'PLACEHOLDER_STRING_FOR_ZCASH_PARAMS_PATH';
}
