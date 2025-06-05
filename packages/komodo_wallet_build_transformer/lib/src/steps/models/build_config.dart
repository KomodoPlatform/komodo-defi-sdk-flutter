import 'package:komodo_wallet_build_transformer/src/steps/models/api/api_build_config.dart';
import 'package:komodo_wallet_build_transformer/src/steps/models/coin_assets/coin_build_config.dart';

class BuildConfig {
  BuildConfig({
    required this.apiConfig,
    required this.coinCIConfig,
  });

  factory BuildConfig.fromJson(Map<String, dynamic> json) {
    return BuildConfig(
      apiConfig: ApiBuildConfig.fromJson(json['api'] as Map<String, dynamic>),
      coinCIConfig:
          CoinBuildConfig.fromJson(json['coins'] as Map<String, dynamic>),
    );
  }

  final ApiBuildConfig apiConfig;
  final CoinBuildConfig coinCIConfig;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'api': apiConfig.toJson(),
        'coins': coinCIConfig.toJson(),
      };

  BuildConfig copyWith({
    ApiBuildConfig? apiConfig,
    CoinBuildConfig? coinCIConfig,
  }) {
    return BuildConfig(
      apiConfig: apiConfig ?? this.apiConfig,
      coinCIConfig: coinCIConfig ?? this.coinCIConfig,
    );
  }
}
