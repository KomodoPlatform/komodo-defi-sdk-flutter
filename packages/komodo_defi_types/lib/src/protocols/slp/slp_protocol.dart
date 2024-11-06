import 'package:komodo_defi_types/komodo_defi_types.dart';

class SlpProtocol extends ProtocolClass {
  SlpProtocol._({
    required super.subClass,
    required super.config,
  });

  factory SlpProtocol.fromJson(JsonMap json) {
    _validateSlpConfig(json);
    return SlpProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
    );
  }

  static void _validateSlpConfig(JsonMap json) {
    final requiredFields = {
      'bchd_urls': 'BCHD URLs',
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

  List<String> get bchdUrls =>
      config.value<List<dynamic>>('bchd_urls').cast<String>();

  @override
  List<String> get requiredServers =>
      config.value<List<dynamic>>('electrum').cast<String>();
}
