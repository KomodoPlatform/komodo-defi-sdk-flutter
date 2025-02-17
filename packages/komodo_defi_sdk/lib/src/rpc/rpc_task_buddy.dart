import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// A class that helps with executing task-based RPC methods by removing
/// the boilerplate code for watching the status of a task.
class TaskShepherd {
  /// Executes a task-based RPC method and returns a stream that emits the
  /// status of the task until it is complete.
  ///
  /// The [initTask] function should return a [NewTaskResponse] that contains
  /// the task ID.
  ///
  /// The [getTaskStatus] function should return the current status of the task
  /// given the task ID.
  static Stream<T> executeTask<T extends BaseResponse>({
    required Future<NewTaskResponse> Function() initTask,
    required Future<T> Function(int taskId) getTaskStatus,
    required bool Function(T) checkTaskStatus,
    Future<void> Function(int taskId)? cancelTask,
    // TODO: Implement mechanism for event-interface watching.
    Duration pollingInterval = const Duration(seconds: 1),
  }) {
    final controller = StreamController<T>();

    scheduleMicrotask(() async {
      try {
        final initResponse = await initTask();
        final taskId = initResponse.taskId;

        if (cancelTask != null) {
          controller.onCancel = () async {
            await cancelTask(taskId);
          };
        }

        var isPaused = false;
        controller
          ..onPause = (() => isPaused = true)
          ..onResume = (() => isPaused = false);

        T? lastResult;

        while (!controller.isClosed) {
          if (isPaused) {
            await Future<void>.delayed(pollingInterval);
            continue;
          }

          final status = await getTaskStatus(taskId);

          if (status != lastResult) {
            controller.add(status);
            lastResult = status;
          }

          if (checkTaskStatus(status)) {
            await controller.close();
            return;
          }

          await Future<void>.delayed(pollingInterval);
        }
      } catch (e, stackTrace) {
        controller.addError(e, stackTrace);
        // await controller.
      }
    });

    return controller.stream;
  }
}

extension TaskRpcBuddy on NewTaskResponse {
  Stream<T> watch<T extends BaseResponse>({
    required Future<T> Function(int taskId) getTaskStatus,
    required bool Function(T) isTaskComplete,
    Future<void> Function(int taskId)? cancelTask,
    Duration pollingInterval = const Duration(seconds: 1),
  }) {
    return TaskShepherd.executeTask<T>(
      initTask: () async => this,
      getTaskStatus: getTaskStatus,
      checkTaskStatus: isTaskComplete,
      cancelTask: cancelTask,
      pollingInterval: pollingInterval,
    );
  }
}

extension TaskRpcBuddyFuture on Future<NewTaskResponse> {
  Stream<T> watch<T extends BaseResponse>({
    required Future<T> Function(int taskId) getTaskStatus,
    required bool Function(T) isTaskComplete,
    Future<void> Function(int taskId)? cancelTask,
    Duration pollingInterval = const Duration(seconds: 1),
  }) {
    return TaskShepherd.executeTask<T>(
      initTask: () async => this,
      getTaskStatus: getTaskStatus,
      checkTaskStatus: isTaskComplete,
      cancelTask: cancelTask,
      pollingInterval: pollingInterval,
    );
  }
}
