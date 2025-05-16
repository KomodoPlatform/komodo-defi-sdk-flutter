// ignore_for_file: avoid_print, unreachable_from_main
/// Represents the links associated with a GitHub file resource.
class Links {
  /// Creates a new instance of the [Links] class.
  const Links({this.self, this.git, this.html});

  /// Creates a new instance of the [Links] class from a JSON map.
  factory Links.fromJson(Map<String, dynamic> data) => Links(
        self: data['self'] as String?,
        git: data['git'] as String?,
        html: data['html'] as String?,
      );

  /// Converts the [Links] instance to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'self': self,
        'git': git,
        'html': html,
      };

  /// The self link.
  final String? self;

  /// The git link.
  final String? git;

  /// The HTML link.
  final String? html;
}
