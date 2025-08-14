class CoinsContentLocator {
  const CoinsContentLocator({
    required this.branch,
    required this.coinsGithubContentUrl,
    this.cdnBranchMirrors,
  });

  final String branch;
  final String coinsGithubContentUrl;
  final Map<String, String>? cdnBranchMirrors;

  Uri buildContentUri(String path, {String? branchOrCommit}) {
    return resolveUri(
      path: path,
      branch: branch,
      coinsGithubContentUrl: coinsGithubContentUrl,
      cdnBranchMirrors: cdnBranchMirrors,
      branchOrCommit: branchOrCommit,
    );
  }

  static Uri resolveUri({
    required String path,
    required String branch,
    required String coinsGithubContentUrl,
    Map<String, String>? cdnBranchMirrors,
    String? branchOrCommit,
  }) {
    final effectiveBranch = branchOrCommit ?? branch;
    final cdnBase = cdnBranchMirrors?[effectiveBranch];
    if (cdnBase != null && cdnBase.isNotEmpty) {
      return Uri.parse('$cdnBase/$path');
    }
    return Uri.parse('$coinsGithubContentUrl/$effectiveBranch/$path');
  }
}
