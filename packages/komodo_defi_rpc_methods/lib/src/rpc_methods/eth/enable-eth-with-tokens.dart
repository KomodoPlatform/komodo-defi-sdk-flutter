// TODO!

// import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

// @Deprecated('TODO: Implement')
// class TaskEnableEthWithTokenInit
//     extends BaseRequest<TaskEnableEthInitResponse, GeneralErrorResponse> {
//   TaskEnableEthWithTokenInit({
//     required String rpcPass,
//     required ApiClient client,
//     required this.ticker,
//     required this.params,
//   }) : super(
//           rpcPass: rpcPass,
//           client: client,
//           method: 'task::enable_eth::init',
//         );

//   final String ticker;
//   final EthActivationParams params;

//   @override
//   Map<String, dynamic> toJson() => {
//         'userpass': rpcPass,
//         'mmrpc': mmrpc,
//         'method': method,
//         'params': {
//           'ticker': ticker,
//           'activation_params': params.toJson(),
//         },
//       };

//   @override
//   Future<TaskEnableEthInitResponse> send() async {
//     final response = await client.sendRequest(toJson());
//     return parseResponse(encodeJson(response));
//   }

//   @override
//   TaskEnableEthInitResponse parseResponse(String responseBody) {
//     final json = decodeJson(responseBody);
//     if (json['error'] != null) {
//       throw GeneralErrorResponse.fromJson(json);
//     }
//     return TaskEnableEthInitResponse.fromJson(json);
//   }
// }

// class EthActivationParams extends ActivationParams {
//   EthActivationParams({
//     required this.nodes,
//     this.swapContractAddress,
//     this.fallbackSwapContract,
//     int? requiredConfirmations,
//     PrivateKeyPolicy privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
//   }) : super(
//           requiredConfirmations: requiredConfirmations,
//           privKeyPolicy: privKeyPolicy,
//         );

//   final List<String> nodes;
//   final String? swapContractAddress;
//   final String? fallbackSwapContract;

//   @override
//   Map<String, dynamic> toJson() => {
//         'nodes': nodes,
//         if (swapContractAddress != null)
//           'swap_contract_address': swapContractAddress,
//         if (fallbackSwapContract != null)
//           'fallback_swap_contract': fallbackSwapContract,
//         if (requiredConfirmations != null)
//           'required_confirmations': requiredConfirmations,
//         'priv_key_policy': privKeyPolicy.toString().split('.').last,
//       };
// }

// class TaskEnableEthInitResponse extends BaseResponse {
//   TaskEnableEthInitResponse({
//     required super.mmrpc,
//     required this.taskId,
//   });

//   final int taskId;

//   factory TaskEnableEthInitResponse.fromJson(Map<String, dynamic> json) {
//     return TaskEnableEthInitResponse(
//       mmrpc: json['mmrpc'],
//       taskId: json['result']['task_id'],
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() => {
//         'mmrpc': mmrpc,
//         'result': {'task_id': taskId},
//       };
// }
