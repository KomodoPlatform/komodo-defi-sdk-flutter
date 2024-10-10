import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class TaskStatusRequest
    extends BaseRequest<TaskStatusResponse, GeneralErrorResponse> {
  TaskStatusRequest({
    required this.taskId,
    required super.rpcPass,
  }) : super(
          method: 'task::enable_utxo::status',
          mmrpc: '2.0',
        );

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
        'userpass': rpcPass,
        'mmrpc': mmrpc,
        'method': method,
        'params': {
          'task_id': taskId,
          'forget_if_finished':
              false, // Default value as per your documentation
        },
      };

  @override
  TaskStatusResponse parseResponse(String responseBody) {
    final json = jsonFromString(responseBody);
    if (json['error'] != null) {
      throw GeneralErrorResponse.parse(json);
    }
    return TaskStatusResponse.parse(json);
  }
}

class TaskStatusResponse extends BaseResponse {
  TaskStatusResponse({
    required super.mmrpc,
    required this.status,
    required this.details,
    required this.isCompleted,
  });

  @override
  factory TaskStatusResponse.parse(Map<String, dynamic> json) {
    return TaskStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: json.value<String>('result', 'status'),
      details: json.value<String>('result', 'details'),
      isCompleted: json.value<String>('result', 'status') ==
          'Ok', // Check if task is completed
    );
  }

  final String status;
  final String details;
  final bool isCompleted;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'status': status,
          'details': details,
        },
      };
}
