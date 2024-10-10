// // ERC20 Protocol Class
// import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
// import 'package:komodo_defi_types/komodo_defi_types.dart';

// // UTXO Protocol Class
// class UTXOProtocol extends ProtocolClass {
//   UTXOProtocol(super.subClass);

//   factory UTXOProtocol.fromJson(CoinSubClass subClass) {
//     return UTXOProtocol(subClass);
//   }
// }

// // import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
// // import 'package:komodo_defi_types/komodo_defi_types.dart';
// // import 'package:types_library/types_library.dart'; // Assuming the types library has the ActivationStrategy interface

// abstract class BaseTaskActivationStrategy implements ActivationStrategy {
//   // Client for making RPC requests

//   BaseTaskActivationStrategy(this.apiClient);
//   @override
//   int? taskId; // The task ID for checking the status

//   final ApiClient apiClient;

//   /// Method to create the RPC request for task initialization.
//   /// Subclasses should implement this to return the appropriate request.
//   BaseRequest<NewTaskResponse, GeneralErrorResponse> createInitRequest(
//     Coin coin,
//   );

//   /// Initialize the task by making an RPC request to start the task.
//   @override
//   Stream<ActivationProgress> activate(Coin coin) async* {
//     yield ActivationProgress(status: 'Initializing task...');

//     try {
//       // Start task using the RPC request class
//       final taskResponse = await _startTask(coin);
//       taskId = taskResponse.taskId;

//       yield ActivationProgress(
//         status: 'Task started (ID: $taskId)',
//       );

//       // Optionally check status immediately after starting
//       yield* checkStatus(coin);
//     } catch (e) {
//       yield ActivationProgress(
//         status: 'Task initialization failed: $e',
//         isComplete: true,
//       );
//     }
//   }

//   /// Check the current status of the task.
//   @override
//   Stream<ActivationProgress> checkStatus(Coin coin) async* {
//     if (taskId == null) {
//       yield ActivationProgress(
//         status: 'No task ID available',
//         isComplete: true,
//       );
//       return;
//     }

//     yield ActivationProgress(
//       status: 'Checking task status...',
//     );

//     try {
//       // Query the status using the task ID
//       final statusResponse = await _checkTaskStatus(taskId!);

//       if (statusResponse.isCompleted) {
//         yield ActivationProgress(status: 'Task completed', isComplete: true);
//       } else {
//         yield ActivationProgress(
//           status: 'Task in progress: ${statusResponse.details}',
//         );
//       }
//     } catch (e) {
//       yield ActivationProgress(
//         status: 'Failed to check task status: $e',
//         isComplete: true,
//       );
//     }
//   }

//   /// Starts the task by executing the RPC request for task initialization
//   Future<NewTaskResponse> _startTask(Coin coin) async {
//     final request = createInitRequest(coin);
//     return await apiClient.execute(request);
//   }

//   /// Check the task status by querying the RPC method
//   Future<TaskStatusResponse> _checkTaskStatus(int taskId) async {
//     // Implement the request to check task status
//     final statusRequest =
//         TaskStatusRequest(taskId: taskId, rpcPass: apiClient.rpcPass);
//     return statusRequest.send(apiClient);
//   }
// }

// // class ERC20Protocol extends ProtocolClass {
// //   ERC20Protocol({
// //     required this.contractAddress,
// //     required this.platform,
// //     required CoinSubClass subClass,
// //   }) : super(subClass);

// //   @override
// //   factory ERC20Protocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return ERC20Protocol(
// //       contractAddress:
// //           json.value<String>('protocol', 'protocol_data', 'contract_address'),
// //       platform: json.value<String>('protocol', 'protocol_data', 'platform'),
// //       subClass: subClass,
// //     );
// //   }
// //   final String contractAddress;
// //   final String platform;
// // }
// // // TENDERMINT Protocol Class
// // class TendermintProtocol extends ProtocolClass {
// //   TendermintProtocol({
// //     required this.chainId,
// //     required this.denom,
// //     required CoinSubClass subClass,
// //   }) : super(subClass);

// //   factory TendermintProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return TendermintProtocol(
// //       chainId: json.value<String>('protocol', 'protocol_data', 'chain_id'),
// //       denom: json.value<String>('protocol', 'protocol_data', 'denom'),
// //       subClass: subClass,
// //     );
// //   }
// //   final String chainId;
// //   final String denom;
// // }

// // // ZHTLC Protocol Class
// // class ZHTLCProtocol extends ProtocolClass {
// //   ZHTLCProtocol(super.subClass);

// //   factory ZHTLCProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return ZHTLCProtocol(subClass);
// //   }
// // }

// // // ETH Protocol Class
// // class EthProtocol extends ProtocolClass {
// //   EthProtocol(super.subClass);

// //   factory EthProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return EthProtocol(subClass);
// //   }
// // }

// // // BCH Protocol Class
// // class BCHProtocol extends ProtocolClass {
// //   BCHProtocol({
// //     required this.slpPrefix,
// //     required CoinSubClass subClass,
// //   }) : super(subClass);

// //   factory BCHProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return BCHProtocol(
// //       slpPrefix: json.value<String>('protocol', 'protocol_data', 'slp_prefix'),
// //       subClass: subClass,
// //     );
// //   }
// //   final String slpPrefix;
// // }

// // // SLPTOKEN Protocol Class
// // class SLPTOKENProtocol extends ProtocolClass {
// //   SLPTOKENProtocol({
// //     required this.tokenId,
// //     required CoinSubClass subClass,
// //   }) : super(subClass);

// //   factory SLPTOKENProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return SLPTOKENProtocol(
// //       tokenId: json.value<String>('protocol', 'protocol_data', 'token_id'),
// //       subClass: subClass,
// //     );
// //   }
// //   final String tokenId;
// // }

// // // QRC20 Protocol Class
// // class QRC20Protocol extends ProtocolClass {
// //   QRC20Protocol({
// //     required this.contractAddress,
// //     required CoinSubClass subClass,
// //   }) : super(subClass);

// //   factory QRC20Protocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return QRC20Protocol(
// //       contractAddress:
// //           json.value<String>('protocol', 'protocol_data', 'contract_address'),
// //       subClass: subClass,
// //     );
// //   }
// //   final String contractAddress;
// // }

// // // QTUM Protocol Class
// // class QTUMProtocol extends ProtocolClass {
// //   QTUMProtocol(super.subClass);

// //   factory QTUMProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return QTUMProtocol(subClass);
// //   }
// // }

// // // TENDERMINTTOKEN Protocol Class
// // class TendermintTokenProtocol extends ProtocolClass {
// //   TendermintTokenProtocol(super.subClass);

// //   factory TendermintTokenProtocol.fromJson(
// //     JsonMap json,
// //     CoinSubClass subClass,
// //   ) {
// //     return TendermintTokenProtocol(subClass);
// //   }
// // }

// // // NFT Protocol Class
// // class NFTProtocol extends ProtocolClass {
// //   NFTProtocol({
// //     required this.platform,
// //     required CoinSubClass subClass,
// //   }) : super(subClass);

// //   factory NFTProtocol.fromJson(JsonMap json, CoinSubClass subClass) {
// //     return NFTProtocol(
// //       platform: json.value<String>('protocol', 'protocol_data', 'platform'),
// //       subClass: subClass,
// //     );
// //   }
// //   final String platform;
// // }

// // // Fallback Unknown Protocol Class
// // class UnknownProtocol extends ProtocolClass {
// //   UnknownProtocol(super.subClass);
// // }
