import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Abstract interface for providing coin configuration data.
abstract class CoinConfigProvider {
  /// Fetches the assets for a specific [commit].
  Future<List<Asset>> getAssetsForCommit(String commit);

  /// Fetches the assets for the provider's default branch or reference.
  Future<List<Asset>> getAssets({String? branch});

  /// Retrieves the latest commit hash for the configured branch.
  /// Optional overrides allow targeting a different branch, API base URL,
  /// or GitHub token for this call only.
  Future<String> getLatestCommit({
    String? branch,
    String? apiBaseUrl,
    String? githubToken,
  });
}
