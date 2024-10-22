import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class GenericTaskActivationStrategy implements ActivationStrategy {
  // BaseTaskActivationStrategy(this.apiClient);
  GenericTaskActivationStrategy();

  @override
  int? taskId; // The task ID for checking the status

  // final ApiClient apiClient;

  // final ActivationRpcData rpcData;

  /// Method to create the RPC request for task initialization.
  BaseRequest<NewTaskResponse, GeneralErrorResponse> createInitRequest(
    Asset coin,
  );

  /// Method to create the RPC request for checking task status.
  BaseRequest<TaskStatusResponse, GeneralErrorResponse> createStatusRequest(
    int taskId,
  );

  @override
  Stream<ActivationProgress> activate(ApiClient apiClient, Asset coin) async* {
    yield ActivationProgress(status: 'Initializing task...');

    try {
      // Start task using the RPC request class
      final taskResponse = await _startTask(apiClient, coin);
      taskId = taskResponse.taskId;

      yield ActivationProgress(
        status: 'Task started (ID: $taskId)',
      );

      yield* checkStatus(apiClient, coin);
    } catch (e) {
      yield ActivationProgress(
        status: 'Task initialization failed: $e',
        errorMessage: (e is GeneralErrorResponse)
            ? e.toJson().toJsonString()
            : e.toString(),
        isComplete: true,
      );

      return;
    }
  }

  @override
  Stream<ActivationProgress> checkStatus(
    ApiClient apiClient,
    Asset coin,
  ) async* {
    if (taskId == null) {
      yield ActivationProgress(
        status: 'No task ID available',
        isComplete: true,
      );
      return;
    }

    yield ActivationProgress(
      status: 'Checking task status...',
    );

    // final controller = StreamController<ActivationProgress>();

    try {
      // while (!controller.isClosed) {
      ActivationProgress? status;
      // TODO: Test whether
      while (status?.isComplete != true) {
        // Query the status using the task ID
        yield status = await _checkTaskStatus(apiClient, taskId!);

        if (status.isComplete) {
          break;
        }

        await Future<void>.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      yield ActivationProgress(
        status: 'Failed to check task status: $e',
        errorMessage: e.toString(),
        isComplete: true,
      );
    }
  }

  Future<NewTaskResponse> _startTask(ApiClient apiClient, Asset coin) async {
    final request = createInitRequest(coin);
    return request.send(apiClient);
  }

  Future<ActivationProgress> _checkTaskStatus(
    ApiClient apiClient,
    int taskId,
  ) async {
    try {
      final response = await createStatusRequest(taskId).send(apiClient);

      return ActivationProgress(
        status: response.status,
        isComplete: response.isCompleted,
      );
    } on GeneralErrorResponse catch (e) {
      if (e.errorType == 'CoinIsAlreadyActivated') {
        return ActivationProgress(
          status: 'Coin activated (was already active)',
          isComplete: true,
        );
      }
      rethrow;
    } catch (e) {
      return ActivationProgress(
        status: 'Failed to check task status: $e',
        errorMessage: e.toString(),
        isComplete: true,
      );
    }
  }
}
