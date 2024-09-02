/// Enum representing the events that can occur during a GitHub download.
enum GitHubDownloadEvent {
  /// The download was successful.
  downloaded,

  /// The download was skipped.
  skipped,

  /// The download failed.
  failed,
}
