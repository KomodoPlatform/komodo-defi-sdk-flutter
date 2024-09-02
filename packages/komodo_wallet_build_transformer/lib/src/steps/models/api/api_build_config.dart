import 'package:komodo_wallet_build_transformer/src/steps/models/api/api_build_platform_config.dart';

class ApiBuildConfig {
  String apiCommitHash;
  String branch;
  bool fetchAtBuildEnabled;
  List<String> sourceUrls;
  Map<String, ApiBuildPlatformConfig> platforms;

  ApiBuildConfig({
    required this.apiCommitHash,
    required this.branch,
    required this.fetchAtBuildEnabled,
    required this.sourceUrls,
    required this.platforms,
  });

  factory ApiBuildConfig.fromJson(Map<String, dynamic> json) {
    return ApiBuildConfig(
      apiCommitHash: json['api_commit_hash'],
      branch: json['branch'],
      fetchAtBuildEnabled: json['fetch_at_build_enabled'],
      sourceUrls: List<String>.from(json['source_urls']),
      platforms: Map<String, ApiBuildPlatformConfig>.from(
        json['platforms'].map(
          (key, value) => MapEntry(key, ApiBuildPlatformConfig.fromJson(value)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_commit_hash': apiCommitHash,
      'branch': branch,
      'fetch_at_build_enabled': fetchAtBuildEnabled,
      'source_urls': sourceUrls,
      'platforms': platforms.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  ApiBuildConfig copyWith({
    String? apiCommitHash,
    String? branch,
    bool? fetchAtBuildEnabled,
    List<String>? sourceUrls,
    Map<String, ApiBuildPlatformConfig>? platforms,
  }) {
    return ApiBuildConfig(
      apiCommitHash: apiCommitHash ?? this.apiCommitHash,
      branch: branch ?? this.branch,
      fetchAtBuildEnabled: fetchAtBuildEnabled ?? this.fetchAtBuildEnabled,
      sourceUrls: sourceUrls ?? this.sourceUrls,
      platforms: platforms ?? this.platforms,
    );
  }
}
