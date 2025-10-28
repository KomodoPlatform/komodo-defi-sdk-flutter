part of 'kdf_event.dart';

/// Task update event for RPC task status changes
/// Event type format: TASK:{taskId}
class TaskEvent extends KdfEvent {
  TaskEvent({required this.taskId, required this.taskData});

  factory TaskEvent.fromJson(JsonMap json, int taskId) {
    return TaskEvent(taskId: taskId, taskData: json);
  }

  @override
  EventTypeString get typeEnum => EventTypeString.task;

  /// The task ID this update is for
  final int taskId;

  /// The task update data
  final JsonMap taskData;

  @override
  String toString() => 'TaskEvent(taskId: $taskId)';
}
