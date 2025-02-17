import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Generic response for new task creation (e.g. `task::enable_utxo::init`).
/// "::init" RPC methods typically return this response.
///
/// E.g.:
/// {
///   "mmrpc": "2.0",
///   "result": {
///     "task_id": 1
///   },
///   "id": null
/// }
class NewTaskResponse extends BaseResponse {
  NewTaskResponse({
    required super.mmrpc,
    required this.taskId,
  });

  @override
  factory NewTaskResponse.parse(Map<String, dynamic> json) {
    return NewTaskResponse(
      mmrpc: json.value<String>('mmrpc'),
      taskId: json.value<int>('result', 'task_id'),
    );
  }

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {'task_id': taskId},
      };
}
