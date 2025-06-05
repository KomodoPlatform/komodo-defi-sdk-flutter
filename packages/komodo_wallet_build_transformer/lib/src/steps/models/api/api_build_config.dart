import 'package:komodo_wallet_build_transformer/src/steps/models/api/api_build_platform_config.dart';

class ApiBuildConfig {
  ApiBuildConfig({
    required this.apiCommitHash,
    required this.branch,
    required this.fetchAtBuildEnabled,
    required this.concurrentDownloadsEnabled,
    required this.sourceUrls,
    required this.platforms,
  });

  factory ApiBuildConfig.fromJson(Map<String, dynamic> json) {
    try {
      return ApiBuildConfig(
        apiCommitHash: _parseString(json, 'api_commit_hash'),
        branch: _parseString(json, 'branch'),
        fetchAtBuildEnabled: _parseBool(json, 'fetch_at_build_enabled'),
        concurrentDownloadsEnabled:
            json['concurrent_downloads_enabled'] as bool? ?? true,
        sourceUrls: _parseStringList(json, 'source_urls'),
        platforms: _parsePlatforms(json),
      );
    } catch (e) {
      throw FormatException('Invalid JSON format for ApiBuildConfig: $e');
    }
  }

  String apiCommitHash;
  String branch;
  bool fetchAtBuildEnabled;
  final bool concurrentDownloadsEnabled;
  List<String> sourceUrls;
  Map<String, ApiBuildPlatformConfig> platforms;

  static String _parseString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException(
        'Expected a string for "$key", but got ${value.runtimeType}',
      );
    }
    return value;
  }

  static bool _parseBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! bool) {
      throw FormatException(
        'Expected a boolean for "$key", but got ${value.runtimeType}',
      );
    }
    return value;
  }

  static List<String> _parseStringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException(
        'Expected a list for "$key", but got ${value.runtimeType}',
      );
    }
    return List<String>.from(
      value.map((e) {
        if (e is! String) {
          throw FormatException(
            'Expected string elements in "$key" list, but found '
            '${e.runtimeType}',
          );
        }
        return e;
      }),
    );
  }

  static Map<String, ApiBuildPlatformConfig> _parsePlatforms(
    Map<String, dynamic> json,
  ) {
    final platforms = json['platforms'];
    if (platforms is! Map<String, dynamic>) {
      throw FormatException(
        'Expected a map for "platforms", but got ${platforms.runtimeType}',
      );
    }
    return Map<String, ApiBuildPlatformConfig>.from(
      platforms.map(
        (key, value) {
          if (value is! Map<String, dynamic>) {
            throw FormatException(
              'Expected a map for platform "$key", but got '
              '${value.runtimeType}',
            );
          }
          return MapEntry(
            key,
            ApiBuildPlatformConfig.fromJson(value),
          );
        },
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_commit_hash': apiCommitHash,
      'branch': branch,
      'fetch_at_build_enabled': fetchAtBuildEnabled,
      'concurrent_downloads_enabled': concurrentDownloadsEnabled,
      'source_urls': sourceUrls,
      'platforms': platforms.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  ApiBuildConfig copyWith({
    String? apiCommitHash,
    String? branch,
    bool? fetchAtBuildEnabled,
    bool? concurrentDownloadsEnabled,
    List<String>? sourceUrls,
    Map<String, ApiBuildPlatformConfig>? platforms,
  }) {
    return ApiBuildConfig(
      apiCommitHash: apiCommitHash ?? this.apiCommitHash,
      branch: branch ?? this.branch,
      fetchAtBuildEnabled: fetchAtBuildEnabled ?? this.fetchAtBuildEnabled,
      concurrentDownloadsEnabled:
          concurrentDownloadsEnabled ?? this.concurrentDownloadsEnabled,
      sourceUrls: sourceUrls ?? this.sourceUrls,
      platforms: platforms ?? this.platforms,
    );
  }
}
