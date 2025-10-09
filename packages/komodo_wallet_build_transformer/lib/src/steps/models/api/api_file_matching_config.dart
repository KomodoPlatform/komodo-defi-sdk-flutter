/// Configuration for matching API files using either a simple keyword or regex pattern.
class ApiFileMatchingConfig {
  ApiFileMatchingConfig({
    this.matchingKeyword,
    this.matchingPattern,
    List<String>? matchingPreference,
  }) : matchingPreference = matchingPreference ?? const <String>[],
       assert(
         matchingKeyword != null || matchingPattern != null,
         'Either matchingKeyword or matchingPattern must be provided',
       );

  factory ApiFileMatchingConfig.fromJson(Map<String, dynamic> json) {
    final pref = json['matching_preference'];
    return ApiFileMatchingConfig(
      matchingKeyword: json['matching_keyword'] as String?,
      matchingPattern: json['matching_pattern'] as String?,
      matchingPreference: pref is List
          ? pref.whereType<String>().toList()
          : const <String>[],
    );
  }

  /// Simple substring to match in the filename
  final String? matchingKeyword;

  /// Regular expression pattern to match against the filename
  final String? matchingPattern;

  /// Optional ranking preferences when multiple files match.
  /// First substring that matches wins. Earlier items have higher priority.
  final List<String> matchingPreference;

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

  /// Given a list of candidate file names, returns the best according to
  /// [matchingPreference]. If no preferences are set or no candidate matches
  /// any preference, the first candidate is returned.
  String choosePreferred(Iterable<String> candidates) {
    final list = candidates.toList();
    if (list.isEmpty) return '';
    if (matchingPreference.isEmpty) return list.first;

    for (final pref in matchingPreference) {
      final found = list.firstWhere((c) => c.contains(pref), orElse: () => '');
      if (found.isNotEmpty) {
        return found;
      }
    }
    return list.first;
  }

  Map<String, dynamic> toJson() => {
    if (matchingKeyword != null) 'matching_keyword': matchingKeyword,
    if (matchingPattern != null) 'matching_pattern': matchingPattern,
    if (matchingPreference.isNotEmpty)
      'matching_preference': matchingPreference,
  };
}
