import 'package:equatable/equatable.dart';

class RuntimeUpdateConfig extends Equatable {
  const RuntimeUpdateConfig({
    required this.bundledCoinsRepoCommit,
    required this.coinsRepoApiUrl,
    required this.coinsRepoContentUrl,
    required this.coinsRepoBranch,
    required this.runtimeUpdatesEnabled,
  });

  factory RuntimeUpdateConfig.fromJson(Map<String, dynamic> json) {
    return RuntimeUpdateConfig(
      bundledCoinsRepoCommit: json['bundled_coins_repo_commit'] as String,
      coinsRepoApiUrl: json['coins_repo_api_url'] as String,
      coinsRepoContentUrl: json['coins_repo_content_url'] as String,
      coinsRepoBranch: json['coins_repo_branch'] as String,
      runtimeUpdatesEnabled: json['runtime_updates_enabled'] as bool,
    );
  }
  final String bundledCoinsRepoCommit;
  final String coinsRepoApiUrl;
  final String coinsRepoContentUrl;
  final String coinsRepoBranch;
  final bool runtimeUpdatesEnabled;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bundled_coins_repo_commit': bundledCoinsRepoCommit,
      'coins_repo_api_url': coinsRepoApiUrl,
      'coins_repo_content_url': coinsRepoContentUrl,
      'coins_repo_branch': coinsRepoBranch,
      'runtime_updates_enabled': runtimeUpdatesEnabled,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    bundledCoinsRepoCommit,
    coinsRepoApiUrl,
    coinsRepoContentUrl,
    coinsRepoBranch,
    runtimeUpdatesEnabled,
  ];
}
