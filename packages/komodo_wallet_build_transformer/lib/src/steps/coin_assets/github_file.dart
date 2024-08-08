import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/links.dart';

/// Represents a file on GitHub.
class GitHubFile {
  /// Creates a new instance of [GitHubFile].
  const GitHubFile({
    required this.name,
    required this.path,
    required this.sha,
    required this.size,
    this.url,
    this.htmlUrl,
    this.gitUrl,
    required this.downloadUrl,
    required this.type,
    this.links,
  });

  /// Creates a new instance of [GitHubFile] from a JSON map.
  factory GitHubFile.fromJson(Map<String, dynamic> data) => GitHubFile(
        name: data['name'] as String,
        path: data['path'] as String,
        sha: data['sha'] as String,
        size: data['size'] as int,
        url: data['url'] as String?,
        htmlUrl: data['html_url'] as String?,
        gitUrl: data['git_url'] as String?,
        downloadUrl: data['download_url'] as String,
        type: data['type'] as String,
        links: data['_links'] == null
            ? null
            : Links.fromJson(data['_links'] as Map<String, dynamic>),
      );

  /// Converts the [GitHubFile] instance to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'path': path,
        'sha': sha,
        'size': size,
        'url': url,
        'html_url': htmlUrl,
        'git_url': gitUrl,
        'download_url': downloadUrl,
        'type': type,
        '_links': links?.toJson(),
      };

  /// The name of the file.
  final String name;

  /// The path of the file.
  final String path;

  /// The SHA value of the file.
  final String sha;

  /// The size of the file in bytes.
  final int size;

  /// The URL of the file.
  final String? url;

  /// The HTML URL of the file.
  final String? htmlUrl;

  /// The Git URL of the file.
  final String? gitUrl;

  /// The download URL of the file.
  final String downloadUrl;

  /// The type of the file.
  final String type;

  /// The links associated with the file.
  final Links? links;
}
