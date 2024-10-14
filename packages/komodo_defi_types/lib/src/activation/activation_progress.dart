import 'package:komodo_defi_types/komodo_defi_types.dart';

class ActivationProgress {
  ActivationProgress({
    required this.status,
    this.progressPercentage,
    this.isComplete = false,
    this.errorMessage,
  });

  final String status;
  final double? progressPercentage; // Nullable, for protocols like ZHTLC
  final bool isComplete;
  final String? errorMessage;

  bool get isSuccess => isComplete && errorMessage == null;

  JsonMap toJson() {
    return {
      'status': status,
      'progressPercentage': progressPercentage,
      'isComplete': isComplete,
      'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return toJson().toJsonString();
  }
}
