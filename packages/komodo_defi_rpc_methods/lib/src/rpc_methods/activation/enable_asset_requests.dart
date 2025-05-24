// // TODO: Split into multiple files

// import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

// class EnableBchWithTokensRequest
//     extends BaseRequest<EnableBchWithTokensResponse, GeneralErrorResponse>
//     with RequestHandlingMixin {
//   EnableBchWithTokensRequest({
//     required String rpcPass,
//     required this.ticker,
//     required this.activationParams,
//     this.addressFormat,
//     this.getBalances = true,
//     this.utxoMergeParams,
//   }) : super(
//           method: 'enable_bch_with_tokens',
//           rpcPass: rpcPass,
//           mmrpc: '2.0',
//           params: activationParams,
//         );

//   final String ticker;
//   final BchActivationParams activationParams;
//   final AddressFormat? addressFormat;
//   final bool getBalances;
//   final UtxoMergeParams? utxoMergeParams;

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       ...super.toJson(),
//       'params': {
//         'ticker': ticker,
//         'activation_params': activationParams.toJson(),
//         if (addressFormat != null) 'address_format': addressFormat!.toJson(),
//         'get_balances': getBalances,
//         if (utxoMergeParams != null)
//           'utxo_merge_params': utxoMergeParams!.toJson(),
//       },
//     };
//   }

//   @override
//   EnableBchWithTokensResponse parse(Map<String, dynamic> json) =>
//       EnableBchWithTokensResponse.parse(json);
// }

// class EnableErc20Request
//     extends BaseRequest<EnableErc20Response, GeneralErrorResponse>
//     with RequestHandlingMixin {
//   EnableErc20Request({
//     required String rpcPass,
//     required this.ticker,
//     required this.activationParams,
//   }) : super(
//           method: 'enable_erc20',
//           rpcPass: rpcPass,
//           mmrpc: '2.0',
//           params: activationParams,
//         );

//   final String ticker;
//   final Erc20ActivationParams activationParams;

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       ...super.toJson(),
//       'params': {
//         'ticker': ticker,
//         'activation_params': activationParams.toJson(),
//       },
//     };
//   }

//   @override
//   EnableErc20Response parse(Map<String, dynamic> json) =>
//       EnableErc20Response.parse(json);
// }

// class EnableTendermintTokenRequest
//     extends BaseRequest<EnableTendermintTokenResponse, GeneralErrorResponse>
//     with RequestHandlingMixin {
//   EnableTendermintTokenRequest({
//     required String rpcPass,
//     required this.ticker,
//     required this.activationParams,
//   }) : super(
//           method: 'enable_tendermint_token',
//           rpcPass: rpcPass,
//           mmrpc: '2.0',
//           params: activationParams,
//         );

//   final String ticker;
//   final CosmosActivationParams activationParams;

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       ...super.toJson(),
//       'params': {
//         'ticker': ticker,
//         'activation_params': activationParams.toJson(),
//       },
//     };
//   }

//   @override
//   EnableTendermintTokenResponse parse(Map<String, dynamic> json) =>
//       EnableTendermintTokenResponse.parse(json);
// }
