/// Represents the result of an operation.
class Result {
  /// Creates a [Result] object with the specified success status and optional
  /// error message.
  const Result({
    required this.success,
    this.error,
  });

  /// Creates a [Result] object indicating a successful operation.
  factory Result.success() => const Result(success: true);

  /// Creates a [Result] object indicating a failed operation with the specified
  /// error message.
  factory Result.error(String error) => Result(success: false, error: error);

  /// Indicates whether the operation was successful.
  final bool success;

  /// The error message associated with a failed operation, or null if the
  /// operation was successful.
  final String? error;
}
