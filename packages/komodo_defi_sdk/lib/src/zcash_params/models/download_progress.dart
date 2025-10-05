import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_progress.freezed.dart';
part 'download_progress.g.dart';

/// Represents the progress of a ZCash parameter file download.
@freezed
abstract class DownloadProgress with _$DownloadProgress {
  /// Creates a DownloadProgress instance.
  const factory DownloadProgress({
    /// The name of the file being downloaded.
    required String fileName,

    /// The number of bytes downloaded so far.
    required int downloaded,

    /// The total number of bytes to download.
    required int total,
  }) = _DownloadProgress;

  const DownloadProgress._();

  /// Creates a DownloadProgress instance from JSON.
  factory DownloadProgress.fromJson(Map<String, dynamic> json) =>
      _$DownloadProgressFromJson(json);

  /// The download progress as a percentage (0.0 to 100.0).
  double get percentage {
    if (total <= 0) return 0;
    return (downloaded / total) * 100;
  }

  /// Whether the download is complete.
  bool get isComplete => downloaded >= total;

  /// Human-readable representation of the download progress.
  String get displayText {
    final downloadedMB = (downloaded / (1024 * 1024)).toStringAsFixed(1);
    final totalMB = (total / (1024 * 1024)).toStringAsFixed(1);
    return '$fileName: ${percentage.toStringAsFixed(1)}% ($downloadedMB/$totalMB MB)';
  }
}
