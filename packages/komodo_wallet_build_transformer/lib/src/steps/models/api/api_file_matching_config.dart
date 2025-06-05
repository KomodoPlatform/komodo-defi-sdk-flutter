/// Configuration for matching API files using either a simple keyword or regex pattern.
class ApiFileMatchingConfig {
  ApiFileMatchingConfig({
    this.matchingKeyword,
    this.matchingPattern,
  }) : assert(
          matchingKeyword != null || matchingPattern != null,
          'Either matchingKeyword or matchingPattern must be provided',
        );

  factory ApiFileMatchingConfig.fromJson(Map<String, dynamic> json) {
    return ApiFileMatchingConfig(
      matchingKeyword: json['matching_keyword'] as String?,
      matchingPattern: json['matching_pattern'] as String?,
    );
  }

  /// Simple substring to match in the filename
  final String? matchingKeyword;

  /// Regular expression pattern to match against the filename
  final String? matchingPattern;

  /// Checks if the given input string matches either the keyword or pattern
  bool matches(String input) {
    if (matchingPattern != null) {
      try {
        final regex = RegExp(matchingPattern!);
        return regex.hasMatch(input);
      } catch (e) {
        throw FormatException(
          'Invalid regex pattern: $matchingPattern',
          e.toString(),
        );
      }
    }
    return matchingKeyword != null && input.contains(matchingKeyword!);
  }

  Map<String, dynamic> toJson() => {
        if (matchingKeyword != null) 'matching_keyword': matchingKeyword,
        if (matchingPattern != null) 'matching_pattern': matchingPattern,
      };
}
