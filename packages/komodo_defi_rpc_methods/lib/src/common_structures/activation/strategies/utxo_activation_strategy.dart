import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class UtxoActivationStrategy extends BaseTaskActivationStrategy {
  UtxoActivationStrategy(
      // super.apiClient,
      {
    required this.rpcData,
    required this.activationParams,
  });

  factory UtxoActivationStrategy.fromJsonConfig(
    // ApiClient apiClient,
    Map<String, dynamic> json,
  ) {
    final rpcData = ActivationRpcData(
        electrum: (json['electrum'] as List<dynamic>?)
            ?.cast<JsonMap>()
            .map(ActivationServers.fromJsonConfig)
            .toList());

    return UtxoActivationStrategy(
      // apiClient, // Pass your API client instance here
      rpcData: rpcData,
      activationParams: UtxoActivationParams.fromJsonConfig(json),
    );
  }

  final ActivationRpcData rpcData;
  final UtxoActivationParams activationParams;

  @override
  BaseRequest<NewTaskResponse, GeneralErrorResponse> createInitRequest(
    Asset coin,
  ) {
    // final utxoParams = UtxoActivationParams.fromJsonConfig(coin.toJson());
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
