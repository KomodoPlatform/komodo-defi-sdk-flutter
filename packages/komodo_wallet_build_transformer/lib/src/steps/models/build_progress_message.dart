/// Represents a build progress message.
class BuildProgressMessage {
  /// Creates a new instance of [BuildProgressMessage].
  ///
  /// The [message] parameter represents the message of the progress.
  /// The [progress] parameter represents the progress value.
  /// The [success] parameter indicates whether the progress was successful or not.
  /// The [finished] parameter indicates whether the progress is finished.
  const BuildProgressMessage({
    required this.message,
    required this.progress,
    required this.success,
    this.finished = false,
  });

  /// The message of the progress.
  final String message;

  /// Indicates whether the progress was successful or not.
  final bool success;

  /// The progress value (percentage).
  final double progress;

  /// Indicates whether the progress is finished.
  final bool finished;
}
