class ApiBuildPlatformConfig {
  ApiBuildPlatformConfig({
    required this.matchingKeyword,
    required this.validZipSha256Checksums,
    required this.path,
  });

  /// Creates an instance of [ApiBuildPlatformConfig] from a JSON object.
  ///
  /// Throws an [ArgumentError] if the object does not match the expected
  /// structure.
  factory ApiBuildPlatformConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('matching_keyword')) {
      throw ArgumentError('missing matching_keyword');
    }

    if (!json.containsKey('valid_zip_sha256_checksums')) {
      throw ArgumentError('missing valid_zip_sha256_checksums');
    }

    if (!json.containsKey('path')) {
      throw ArgumentError('missing path');
    }

    return ApiBuildPlatformConfig(
      matchingKeyword: json['matching_keyword'] as String,
      validZipSha256Checksums:
          List<String>.from(json['valid_zip_sha256_checksums'] as List),
      path: json['path'] as String,
    );
  }

  String matchingKeyword;
  List<String> validZipSha256Checksums;
  String path;

  Map<String, dynamic> toJson() {
    return {
      'matching_keyword': matchingKeyword,
      'valid_zip_sha256_checksums': validZipSha256Checksums,
      'path': path,
    };
  }

  ApiBuildPlatformConfig copyWith({
    String? matchingKeyword,
    List<String>? validZipSha256Checksums,
    String? path,
  }) {
    return ApiBuildPlatformConfig(
      matchingKeyword: matchingKeyword ?? this.matchingKeyword,
      validZipSha256Checksums:
          validZipSha256Checksums ?? this.validZipSha256Checksums,
      path: path ?? this.path,
    );
  }
}
