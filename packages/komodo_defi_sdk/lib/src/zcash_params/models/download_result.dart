import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_result.freezed.dart';
part 'download_result.g.dart';

/// Represents the result of a ZCash parameters download operation.
@freezed
abstract class DownloadResult with _$DownloadResult {
  /// Creates a successful download result.
  const factory DownloadResult.success({
    /// The path to the downloaded ZCash parameters directory.
    required String paramsPath,
  }) = DownloadResultSuccess;

  /// Creates a failed download result with an error message.
  const factory DownloadResult.failure({
    /// Error message if the download failed.
    required String error,
  }) = DownloadResultFailure;

  /// Creates a DownloadResult instance from JSON.
  factory DownloadResult.fromJson(Map<String, dynamic> json) =>
      _$DownloadResultFromJson(json);
}
