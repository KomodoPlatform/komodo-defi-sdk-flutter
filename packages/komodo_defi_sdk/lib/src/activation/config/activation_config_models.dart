import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ZhtlcUserConfig {
  const ZhtlcUserConfig({
    required this.zcashParamsPath,
    this.scanBlocksPerIteration = 1000,
    this.scanIntervalMs = 0,
  });

  final String zcashParamsPath;
  final int scanBlocksPerIteration;
  final int scanIntervalMs;

  JsonMap toJson() => {
        'zcashParamsPath': zcashParamsPath,
        'scanBlocksPerIteration': scanBlocksPerIteration,
        'scanIntervalMs': scanIntervalMs,
      };

  factory ZhtlcUserConfig.fromJson(JsonMap json) => ZhtlcUserConfig(
        zcashParamsPath: json.value<String>('zcashParamsPath'),
        scanBlocksPerIteration:
            json.valueOrNull<int>('scanBlocksPerIteration') ?? 1000,
        scanIntervalMs: json.valueOrNull<int>('scanIntervalMs') ?? 0,
      );
}

abstract class ActivationConfigMapper {
  static JsonMap encode(Object config) {
    if (config is ZhtlcUserConfig) return config.toJson();
    throw UnsupportedError('Unsupported config type: ${config.runtimeType}');
  }

  static T decode<T>(JsonMap json) {
    if (T == ZhtlcUserConfig) return ZhtlcUserConfig.fromJson(json) as T;
    throw UnsupportedError('Unsupported type for decode: $T');
  }
}

