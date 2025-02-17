// class BchWithTokensBatchStrategy implements BatchActivationStrategy {
//   @override
//   Future<void> activate(
//       ApiClient client, Asset parent, List<Asset> children) async {
//     if (parent.protocol is! BchProtocol) {
//       throw ArgumentError('Parent must be BCH');
//     }

//     final params = BchActivationParams(
//       electrumServers: parent.protocol.servers,
//       bchdUrls: parent.protocol.bchdUrls,
//     );

//     final slpTokens = children
//         .map((child) => TokensRequest(
//               ticker: child.id.id,
//               requiredConfirmations: 3,
//             ))
//         .toList();

//     await client.rpc.generalActivation.enableBchWithTokens(
//       ticker: parent.id.id,
//       activationParams: params,
//       slpTokensRequests: slpTokens,
//       getBalances: true,
//     );
//   }
// }
