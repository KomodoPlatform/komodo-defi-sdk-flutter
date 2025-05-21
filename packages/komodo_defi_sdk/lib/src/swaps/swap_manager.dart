import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager class for swap related functionality.
class SwapManager {
  SwapManager(this._client);

  final ApiClient _client;

  /// Fetch a quote for a classic 1inch swap.
  Future<OneInchClassicSwapQuote> getClassicQuote({
    required String base,
    required String rel,
    required num amount,
    num? fee,
  }) async {
    final response = await _client.rpc.swap.oneInchClassicQuote(
      OneInchV6ClassicSwapQuoteRequest(
        rpcPass: _client.rpcPass ?? '',
        base: base,
        rel: rel,
        amount: amount,
        fee: fee,
      ),
    );
    return response.result;
  }

  /// Create a classic 1inch swap transaction.
  Future<OneInchClassicSwapCreate> createClassicSwap({
    required String base,
    required String rel,
    required num amount,
    required num slippage,
  }) async {
    final response = await _client.rpc.swap.oneInchClassicCreate(
      OneInchV6ClassicSwapCreateRequest(
        rpcPass: _client.rpcPass ?? '',
        base: base,
        rel: rel,
        amount: amount,
        slippage: slippage,
      ),
    );
    return response.result;
  }

  /// Get available tokens for swaps on a given chain.
  Future<Map<String, OneInchTokenInfo>> getClassicTokens(int chainId) async {
    final response = await _client.rpc.swap.oneInchClassicTokens(chainId);
    return response.result.tokens;
  }

  /// Get available liquidity sources for swaps on a given chain.
  Future<List<OneInchProtocolImage>> getClassicLiquiditySources(
    int chainId,
  ) async {
    final response = await _client.rpc.swap.oneInchClassicLiquiditySources(
      chainId,
    );
    return response.result.protocols;
  }

  /// Initiate a buy swap using legacy RPC.
  Stream<SwapStatus> buy({
    required String base,
    required String rel,
    required Decimal volume,
  }) async* {
    final response = await _client.rpc.swap.buy(
      BuyRequest(
        rpcPass: _client.rpcPass ?? '',
        base: base,
        rel: rel,
        volume: volume,
      ),
    );
    yield* watchSwapStatus(response.result.uuid);
  }

  /// Initiate a sell swap using legacy RPC.
  Stream<SwapStatus> sell({
    required String base,
    required String rel,
    required Decimal volume,
  }) async* {
    final response = await _client.rpc.swap.sell(
      SellRequest(
        rpcPass: _client.rpcPass ?? '',
        base: base,
        rel: rel,
        volume: volume,
      ),
    );
    yield* watchSwapStatus(response.result.uuid);
  }

  /// Watch swap status updates for given [uuid].
  Stream<SwapStatus> watchSwapStatus(
    String uuid, {
    Duration interval = const Duration(seconds: 5),
  }) async* {
    while (true) {
      final status = (await _client.rpc.swap.mySwapStatus(uuid)).swap;
      yield status;
      if (status.isFinished) break;
      await Future.delayed(interval);
    }
  }

  /// Get list of active swaps.
  Future<List<SwapStatus>> activeSwaps() async {
    final response = await _client.rpc.swap.activeSwaps();
    return response.swaps;
  }

  /// Get recent swap history.
  Future<List<SwapStatus>> recentSwaps({int? limit}) async {
    final response = await _client.rpc.swap.myRecentSwaps(limit: limit);
    return response.swaps;
  }
}
