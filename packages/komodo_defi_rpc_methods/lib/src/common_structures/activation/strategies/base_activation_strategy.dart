import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class BaseTaskActivationStrategy implements ActivationStrategy {
  // BaseTaskActivationStrategy(this.apiClient);
  BaseTaskActivationStrategy();

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

      // Optionally check status immediately after starting
      yield* checkStatus(apiClient, coin);
    } catch (e) {
      final isGeneralError = e is GeneralErrorResponse;

      if (isGeneralError && e.errorType == 'CoinIsAlreadyActivated') {
        yield ActivationProgress(
          status: 'Coin activated (was already active)',
          isComplete: true,
        );
      }

      yield ActivationProgress(
        status: 'Task initialization failed: $e',
        errorMessage: (e is GeneralErrorResponse)
            ? e.toJson().toJsonString()
            : e.toString(),
        isComplete: true,
      );
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

    try {
      // Query the status using the task ID
      final statusResponse = await _checkTaskStatus(apiClient, taskId!);

      if (statusResponse.isCompleted) {
        yield ActivationProgress(status: 'Task completed', isComplete: true);
      } else {
        yield ActivationProgress(
          status: 'Task in progress: ${statusResponse.details}',
        );
      }
    } catch (e) {
      yield ActivationProgress(
        status: 'Failed to check task status: $e',
        isComplete: true,
      );
    }
  }

  Future<NewTaskResponse> _startTask(ApiClient apiClient, Asset coin) async {
    final request = createInitRequest(coin);
    return request.send(apiClient);
  }

  Future<TaskStatusResponse> _checkTaskStatus(
    ApiClient apiClient,
    int taskId,
  ) async {
    final request = createStatusRequest(taskId);
    return request.send(apiClient);
  }
}
