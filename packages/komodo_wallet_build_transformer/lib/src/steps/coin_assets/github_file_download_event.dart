import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/github_download_event.dart';

/// Represents an event for downloading a GitHub file.
///
/// This event contains information about the download event and the local path where the file will be saved.
/// Represents an event for downloading a GitHub file.
class GitHubFileDownloadEvent {
  /// Creates a new [GitHubFileDownloadEvent] with the specified [event] and [localPath].
  GitHubFileDownloadEvent({
    required this.event,
    required this.localPath,
  });

  /// The download event.
  final GitHubDownloadEvent event;

  /// The local path where the file will be saved.
  final String localPath;
}
