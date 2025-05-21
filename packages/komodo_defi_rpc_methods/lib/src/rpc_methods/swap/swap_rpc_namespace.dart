import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'active_swaps.dart';
import 'buy.dart';
import 'buy_sell_response.dart';
import 'my_recent_swaps.dart';
import 'my_swap_status.dart';
import 'sell.dart';

class SwapMethodsNamespace extends BaseRpcMethodNamespace {
  SwapMethodsNamespace(super.client);

  Future<OneInchV6ClassicSwapQuoteResponse> oneInchClassicQuote(
    OneInchV6ClassicSwapQuoteRequest request,
  ) => execute(request);

  Future<OneInchV6ClassicSwapCreateResponse> oneInchClassicCreate(
    OneInchV6ClassicSwapCreateRequest request,
  ) => execute(request);

  Future<OneInchV6ClassicSwapTokensResponse> oneInchClassicTokens(
    int chainId,
  ) => execute(
    OneInchV6ClassicSwapTokensRequest(rpcPass: rpcPass ?? '', chainId: chainId),
  );

  Future<OneInchV6ClassicSwapLiquiditySourcesResponse>
  oneInchClassicLiquiditySources(int chainId) => execute(
    OneInchV6ClassicSwapLiquiditySourcesRequest(
      rpcPass: rpcPass ?? '',
      chainId: chainId,
    ),
  );

  Future<BuySellResponse> buy(BuyRequest request) => execute(request);

  Future<BuySellResponse> sell(SellRequest request) => execute(request);

  Future<MyRecentSwapsResponse> myRecentSwaps({int? limit}) =>
      execute(MyRecentSwapsRequest(rpcPass: rpcPass ?? '', limit: limit));

  Future<MySwapStatusResponse> mySwapStatus(String uuid) =>
      execute(MySwapStatusRequest(rpcPass: rpcPass ?? '', uuid: uuid));

  Future<ActiveSwapsResponse> activeSwaps() =>
      execute(ActiveSwapsRequest(rpcPass: rpcPass ?? ''));
}
