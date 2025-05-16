import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:meta/meta.dart';

/// Represents the current state and progress of an activation operation
@immutable
class ActivationProgress extends Equatable {
  const ActivationProgress({
    required this.status,
    this.progressPercentage,
    this.isComplete = false,
    this.errorMessage,
    this.progressDetails,
  });

  /// Factory for successful completion
  factory ActivationProgress.success({ActivationProgressDetails? details}) {
    return ActivationProgress(
      status: 'Activation completed successfully',
      progressPercentage: 100,
      isComplete: true,
      progressDetails: details?.copyWith(
        currentStep: 'complete',
        completedAt: DateTime.now(),
      ),
    );
  }

  factory ActivationProgress.alreadyActiveSuccess({
    required String assetName,
    int childCount = 0,
  }) {
    return ActivationProgress(
      status: 'Activation completed successfully',
      progressPercentage: 100,
      isComplete: true,
      progressDetails: ActivationProgressDetails(
        currentStep: 'complete',
        stepCount: 1,
        additionalInfo: {
          'primaryAsset': assetName,
          'alreadyActive': true,
          'childCount': childCount,
        },
        completedAt: DateTime.now(),
      ),
    );
  }

  /// Factory for error states
  factory ActivationProgress.error({
    required String message,
    String? errorCode,
    String? details,
    StackTrace? stackTrace,
  }) {
    return ActivationProgress(
      status: 'Activation failed',
      errorMessage: message,
      isComplete: true,
      progressDetails: ActivationProgressDetails(
        currentStep: 'error',
        stepCount: 1,
        errorCode: errorCode,
        errorDetails: details,
        stackTrace: stackTrace?.toString(),
      ),
    );
  }

  final String status;
  final double? progressPercentage;
  final bool isComplete;
  final String? errorMessage;
  final ActivationProgressDetails? progressDetails;

  bool get isSuccess => isComplete && errorMessage == null;
  bool get isError => errorMessage != null;

  /// Returns a formatted message suitable for user display
  String get userMessage {
    if (isError) {
      return 'Error: $errorMessage';
    }
    final progress = progressPercentage != null
        ? ' (${progressPercentage!.toStringAsFixed(1)}%)'
        : '';
    return '$status$progress';
  }

  /// Creates a copy with updated fields
  ActivationProgress copyWith({
    String? status,
    double? progressPercentage,
    bool? isComplete,
    String? errorMessage,
    ActivationProgressDetails? progressDetails,
  }) {
    return ActivationProgress(
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isComplete: isComplete ?? this.isComplete,
      errorMessage: errorMessage ?? this.errorMessage,
      progressDetails: progressDetails ?? this.progressDetails,
    );
  }

  @override
  List<Object?> get props => [
        status,
        progressPercentage,
        isComplete,
        errorMessage,
        progressDetails,
      ];

  JsonMap toJson() => {
        'status': status,
        if (progressPercentage != null)
          'progressPercentage': progressPercentage,
        'isComplete': isComplete,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (progressDetails != null) 'details': progressDetails!.toJson(),
      };
}

/// Detailed information about the activation progress
@immutable
class ActivationProgressDetails extends Equatable {
  const ActivationProgressDetails({
    required this.currentStep,
    required this.stepCount,
    this.additionalInfo = const {},
    this.errorCode,
    this.errorDetails,
    this.stackTrace,
    this.startedAt,
    this.completedAt,
  });

  final String currentStep;
  final int stepCount;
  final JsonMap additionalInfo;
  final String? errorCode;
  final String? errorDetails;
  final String? stackTrace;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Duration? get duration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  ActivationProgressDetails copyWith({
    String? currentStep,
    int? stepCount,
    JsonMap? additionalInfo,
    String? errorCode,
    String? errorDetails,
    String? stackTrace,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ActivationProgressDetails(
      currentStep: currentStep ?? this.currentStep,
      stepCount: stepCount ?? this.stepCount,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      errorCode: errorCode ?? this.errorCode,
      errorDetails: errorDetails ?? this.errorDetails,
      stackTrace: stackTrace ?? this.stackTrace,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        stepCount,
        additionalInfo,
        errorCode,
        errorDetails,
        stackTrace,
        startedAt,
        completedAt,
      ];

  JsonMap toJson() => {
        'currentStep': currentStep,
        'stepCount': stepCount,
        'additionalInfo': additionalInfo,
        if (errorCode != null) 'errorCode': errorCode,
        if (errorDetails != null) 'errorDetails': errorDetails,
        if (stackTrace != null) 'stackTrace': stackTrace,
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        if (duration != null) 'duration': duration!.inMilliseconds,
      };
}

/// Helper for tracking multi-asset activation progress
class BatchActivationProgress {
  BatchActivationProgress(this.assets);

  final List<Asset> assets;
  final _progress = <AssetId, ActivationProgress>{};
  final _startTimes = <AssetId, DateTime>{};

  void updateProgress(Asset asset, ActivationProgress progress) {
    if (!_startTimes.containsKey(asset.id)) {
      _startTimes[asset.id] = DateTime.now();
    }

    final details = progress.progressDetails?.copyWith(
          startedAt: _startTimes[asset.id],
        ) ??
        ActivationProgressDetails(
          currentStep: 'unknown',
          stepCount: 1,
          startedAt: _startTimes[asset.id],
        );

    _progress[asset.id] = progress.copyWith(
      progressDetails: details,
    );
  }

  double get overallProgress {
    if (_progress.isEmpty) return 0;

    final progressValues =
        _progress.values.map((p) => p.progressPercentage ?? 0).toList();

    return progressValues.reduce((a, b) => a + b) / assets.length;
  }

  bool get isComplete =>
      _progress.length == assets.length &&
      _progress.values.every((p) => p.isComplete);

  List<String> get pendingAssets => assets
      .where(
        (a) => !_progress.containsKey(a.id) || !_progress[a.id]!.isComplete,
      )
      .map((a) => a.id.name)
      .toList();

  List<String> get failedAssets => assets
      .where((a) => _progress[a.id]?.isError ?? false)
      .map((a) => a.id.name)
      .toList();

  JsonMap toJson() => {
        'overallProgress': overallProgress,
        'isComplete': isComplete,
        'pendingAssets': pendingAssets,
        'failedAssets': failedAssets,
        'details': _progress.map(
          (id, progress) => MapEntry(id.toString(), progress.toJson()),
        ),
      };
}
