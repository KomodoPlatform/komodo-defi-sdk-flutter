import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    hide SwapStatus;
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manages swap operations using legacy RPC methods
class SwapManager {
  /// Creates a new instance of [SwapManager]
  /// with the provided [ApiClient], [IAssetProvider], and [ActivationManager].
  /// This manager handles swap operations, including previewing swaps,
  /// executing swaps, and managing active swaps.
  SwapManager(this._client, this._assetProvider, this._activationManager);

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final ActivationManager _activationManager;
  final _activeSwaps = <String, StreamController<SwapProgress>>{};
  final _strategyFactory = const SwapStrategyFactory();

  /// Preview a swap operation to get fees and trade details
  Future<SwapPreview> previewSwap(SwapParameters parameters) async {
    try {
      // Ensure both assets are activated
      await _ensureAssetsActivated([parameters.base, parameters.rel]);

      // Use trade preimage to get swap preview
      final response = await _client.rpc.swap.tradePreimage(
        base: parameters.base.id,
        rel: parameters.rel.id,
        swapMethod: parameters.swapMethod,
        price: parameters.price,
        volume: parameters.volume,
      );

      final result = response.result;

      return SwapPreview(
        baseCoinFee: TradingFee(
          coin: result.baseCoinFee.coin,
          amount: Decimal.parse(result.baseCoinFee.amount),
        ),
        relCoinFee: TradingFee(
          coin: result.relCoinFee.coin,
          amount: Decimal.parse(result.relCoinFee.amount),
        ),
        totalFees:
            result.totalFees
                .map(
                  (fee) => TradingFee(
                    coin: fee.coin,
                    amount: Decimal.parse(fee.amount),
                  ),
                )
                .toList(),
        volume:
            result.volume != null
                ? Decimal.parse(result.volume!)
                : parameters.volume,
        takerFee:
            result.takerFee != null
                ? TradingFee(
                  coin: result.takerFee!.coin,
                  amount: Decimal.parse(result.takerFee!.amount),
                )
                : null,
        feeToSendTakerFee:
            result.feeToSendTakerFee != null
                ? TradingFee(
                  coin: result.feeToSendTakerFee!.coin,
                  amount: Decimal.parse(result.feeToSendTakerFee!.amount),
                )
                : null,
      );
    } catch (e, s) {
      if (e is SwapException) {
        rethrow;
      }
      throw SwapException(
        'Preview failed: $e',
        SwapException.mapErrorToCode(e.toString()),
      );
    }
  }

  /// Execute a swap operation using the specified strategy
  Stream<SwapProgress> swap(
    SwapParameters parameters, {
    SwapStrategyType strategy = SwapStrategyType.smart,
  }) async* {
    final swapStrategy = _strategyFactory.createStrategy(strategy);

    yield* swapStrategy.execute(
      parameters,
      _client,
      _assetProvider,
      _activationManager,
      _activeSwaps,
    );
  }

  /// Execute a swap operation using a custom strategy
  Stream<SwapProgress> swapWithStrategy(
    SwapParameters parameters,
    SwapStrategy strategy,
  ) async* {
    yield* strategy.execute(
      parameters,
      _client,
      _assetProvider,
      _activationManager,
      _activeSwaps,
    );
  }

  /// Get available swap strategies with their descriptions
  Map<SwapStrategyType, String> get availableStrategies =>
      _strategyFactory.availableStrategies;

  /// Get the default swap strategy
  SwapStrategy get defaultStrategy => _strategyFactory.defaultStrategy;

  /// Cancel an active swap/order
  Future<bool> cancelSwap(String uuid) async {
    try {
      final response = await _client.rpc.swap.cancelOrderLegacy(uuid: uuid);
      return response.result == 'success';
    } catch (e) {
      return false;
    } finally {
      await _activeSwaps[uuid]?.close();
      _activeSwaps.remove(uuid);
    }
  }

  /// Get the maximum volume available for trading
  Future<Decimal> getMaxTradableVolume(AssetId assetId) async {
    try {
      await _ensureAssetsActivated([assetId]);

      final response = await _client.rpc.swap.maxMakerVol(coin: assetId.id);
      return Decimal.parse(response.volume.decimal);
    } catch (e) {
      throw SwapException(
        'Failed to get max tradable volume: $e',
        SwapException.mapErrorToCode(e.toString()),
      );
    }
  }

  /// Cancel all orders for a specific coin or all orders
  Future<bool> cancelAllOrders({AssetId? assetId}) async {
    try {
      final cancelBy =
          assetId != null
              ? CancelByCoin(data: CancelByCoinData(ticker: assetId.id))
              : const CancelByAll();

      final response = await _client.rpc.swap.cancelAllOrdersLegacy(
        cancelBy: cancelBy,
      );

      return response.result.cancelled.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _ensureAssetsActivated(List<AssetId> assetIds) async {
    for (final assetId in assetIds) {
      final assets = _assetProvider.findAssetsByConfigId(assetId.id);
      if (assets.isEmpty) {
        throw SwapException(
          'Asset ${assetId.id} not found',
          SwapErrorCode.assetNotActivated,
        );
      }

      final asset = assets.first;
      final activationStatus =
          await _activationManager.activateAsset(asset).last;

      if (activationStatus.isComplete && !activationStatus.isSuccess) {
        throw SwapException(
          'Failed to activate asset ${assetId.id}',
          SwapErrorCode.assetNotActivated,
        );
      }
    }
  }

  /// Cleanup any active swaps
  Future<void> dispose() async {
    final swaps = _activeSwaps.entries.toList();
    _activeSwaps.clear();

    for (final swap in swaps) {
      await swap.value.close();
    }
  }
}
