// import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
// import 'package:komodo_defi_sdk/src/activation/base_strategies/batch_activation.dart';
// import 'package:komodo_defi_sdk/src/assets/asset_manager.dart';
// import 'package:komodo_defi_types/komodo_defi_types.dart';

// /// Handles activation of ETH and ERC20 tokens together
// class EthWithTokensBatchStrategy implements BatchActivationStrategy {
//   @override
//   Future<void> activate(
//     ApiClient client,
//     Asset parent,
//     List<Asset> children,
//   ) async {
//     // Validate parent is ETH
//     if (parent.protocol is! Erc20Protocol) {
//       throw ArgumentError('Parent must be ETH');
//     }

//     // Convert children to TokensRequest format
//     final tokenRequests =
//         children.map((child) => TokensRequest(ticker: child.id.id)).toList();

//     // Create ETH activation params with tokens
//     final params = (parent
//             .activationStrategy(dependencies: children)
//             .activationParams as EthActivationParams)
//         .copyWith(erc20Tokens: tokenRequests);

//     // Enable ETH with tokens
//     await client.rpc.erc20.enableEthWithTokens(
//       ticker: parent.id.id,
//       params: params,
//     );
//   }
// }
