import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class UtxoActivationStrategy extends GenericTaskActivationStrategy {
  UtxoActivationStrategy({
    required this.activationParams,
  }) : super(activationParams: activationParams);

  factory UtxoActivationStrategy.fromJsonConfig(Map<String, dynamic> json) {
    return UtxoActivationStrategy(
      activationParams: UtxoActivationParams.fromJsonConfig(json),
    );
  }

  @override
  final UtxoActivationParams activationParams;

  @override
  BaseRequest<NewTaskResponse, GeneralErrorResponse> createInitRequest(
    Asset coin,
  ) {
    return TaskEnableUtxoInit(
      ticker: coin.id.id,
      params: activationParams,
    );
  }

  @override
  BaseRequest<TaskStatusResponse, GeneralErrorResponse> createStatusRequest(
    int taskId,
  ) {
    return TaskStatusRequest(
      taskId: taskId, rpcPass: null, // Injected by the API client
    );
  }
}
