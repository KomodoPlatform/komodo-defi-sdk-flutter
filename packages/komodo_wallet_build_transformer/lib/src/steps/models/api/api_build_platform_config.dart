class ApiBuildPlatformConfig {
  String matchingKeyword;
  List<String> validZipSha256Checksums;
  String path;

  ApiBuildPlatformConfig({
    required this.matchingKeyword,
    required this.validZipSha256Checksums,
    required this.path,
  });

  factory ApiBuildPlatformConfig.fromJson(Map<String, dynamic> json) {
    return ApiBuildPlatformConfig(
      matchingKeyword: json['matching_keyword'],
      validZipSha256Checksums:
          List<String>.from(json['valid_zip_sha256_checksums']),
      path: json['path'],
    );
  }

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
