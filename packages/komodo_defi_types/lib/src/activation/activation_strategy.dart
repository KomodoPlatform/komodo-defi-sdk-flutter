import 'dart:async';

import 'package:komodo_defi_types/types.dart';

abstract class ActivationStrategy {
  int? taskId; // For task-based activation processes (if needed)

  // Initiates the activation process and streams progress updates
  Stream<ActivationProgress> activate(ApiClient apiClient, Asset coin);

  // Checks the current status of an already initiated activation
  Stream<ActivationProgress> checkStatus(ApiClient apiClient, Asset coin);
}

class PlaceholderStrategy implements ActivationStrategy {
  @override
  Stream<ActivationProgress> activate(ApiClient apiClient, Asset coin) async* {
    yield ActivationProgress(status: 'Placeholder activation started');
  }

  @override
  Stream<ActivationProgress> checkStatus(
    ApiClient apiClient,
    Asset coin,
  ) async* {
    yield ActivationProgress(status: 'Placeholder status check');
  }

  @override
  int? taskId;
}
