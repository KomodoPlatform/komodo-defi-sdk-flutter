import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    hide SwapStatus;
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manages swap operations using legacy RPC methods
class SwapManager {
  SwapManager(this._client, this._assetProvider, this._activationManager);

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final ActivationManager _activationManager;
  final _activeSwaps = <String, StreamController<SwapProgress>>{};

  /// Preview a swap operation to get fees and trade details
  Future<SwapPreview> previewSwap(SwapParameters parameters) async {
    try {
      // Ensure both assets are activated
      await _ensureAssetsActivated([parameters.base, parameters.rel]);

      // Use trade preimage to get swap preview
      final response = await _client.rpc.swap.tradePreimage(
        base: parameters.base,
        rel: parameters.rel,
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
    } catch (e) {
      if (e is SwapException) {
        rethrow;
      }
      throw SwapException(
        'Preview failed: $e',
        SwapException.mapErrorToCode(e.toString()),
      );
    }
  }

  /// Execute a swap operation
  Stream<SwapProgress> swap(SwapParameters parameters) async* {
    StreamController<SwapProgress>? controller;
    String? uuid;

    try {
      // Ensure both assets are activated
      await _ensureAssetsActivated([parameters.base, parameters.rel]);

      yield const SwapProgress(
        status: SwapStatus.initializing,
        message: 'Initializing swap...',
      );

      // Check for existing orders using bestOrders
      yield const SwapProgress(
        status: SwapStatus.searchingForOrders,
        message: 'Searching for matching orders...',
      );

      final bestOrders = await _client.rpc.swap.bestOrders(
        coin: parameters.base,
        action: 'sell',
        requestBy: RequestByVolume(value: parameters.volume.toDouble()),
        excludeMine: true,
      );

      // If there are matching orders, act as taker
      if (bestOrders.orders.isNotEmpty) {
        yield const SwapProgress(
          status: SwapStatus.placingTakerOrder,
          message: 'Placing taker order...',
        );

        final sellResponse = await _client.rpc.swap.sellLegacy(
          base: parameters.base,
          rel: parameters.rel,
          price: parameters.price,
          volume: parameters.volume,
          minVolume: parameters.minVolume,
          baseConfs: parameters.baseConfs,
          baseNota: parameters.baseNota,
          relConfs: parameters.relConfs,
          relNota: parameters.relNota,
          saveInHistory: parameters.saveInHistory,
        );

        uuid = sellResponse.result.uuid;
        controller = StreamController<SwapProgress>();
        _activeSwaps[uuid] = controller;

        yield SwapProgress(
          status: SwapStatus.inProgress,
          message: 'Taker order placed. Swap in progress...',
          uuid: uuid,
          swapResult: SwapResult(
            uuid: sellResponse.result.uuid,
            base: sellResponse.result.base,
            rel: sellResponse.result.rel,
            price: sellResponse.result.baseAmountRat,
            volume: Decimal.parse(sellResponse.result.baseAmount),
            orderType: 'taker',
          ),
        );

        yield SwapProgress(
          status: SwapStatus.complete,
          message: 'Swap completed successfully',
          uuid: uuid,
          swapResult: SwapResult(
            uuid: sellResponse.result.uuid,
            base: sellResponse.result.base,
            rel: sellResponse.result.rel,
            price: sellResponse.result.baseAmountRat,
            volume: Decimal.parse(sellResponse.result.baseAmount),
            orderType: 'taker',
          ),
        );
      } else {
        // No matching orders, act as maker
        yield const SwapProgress(
          status: SwapStatus.placingMakerOrder,
          message: 'No matching orders found. Placing maker order...',
        );

        final setPriceResponse = await _client.rpc.swap.setPriceLegacy(
          base: parameters.base,
          rel: parameters.rel,
          price: parameters.price,
          volume: parameters.volume,
          minVolume: parameters.minVolume,
          baseConfs: parameters.baseConfs,
          baseNota: parameters.baseNota,
          relConfs: parameters.relConfs,
          relNota: parameters.relNota,
          saveInHistory: parameters.saveInHistory,
        );

        uuid = setPriceResponse.result.uuid;
        controller = StreamController<SwapProgress>();
        _activeSwaps[uuid] = controller;

        yield SwapProgress(
          status: SwapStatus.inProgress,
          message: 'Maker order placed. Waiting for match...',
          uuid: uuid,
          swapResult: SwapResult(
            uuid: setPriceResponse.result.uuid,
            base: setPriceResponse.result.base,
            rel: setPriceResponse.result.rel,
            price: Decimal.parse(setPriceResponse.result.price),
            volume: Decimal.parse(setPriceResponse.result.maxBaseVol),
            orderType: 'maker',
            createdAt: setPriceResponse.result.createdAt,
          ),
        );

        yield SwapProgress(
          status: SwapStatus.complete,
          message: 'Maker order placed successfully',
          uuid: uuid,
          swapResult: SwapResult(
            uuid: setPriceResponse.result.uuid,
            base: setPriceResponse.result.base,
            rel: setPriceResponse.result.rel,
            price: Decimal.parse(setPriceResponse.result.price),
            volume: Decimal.parse(setPriceResponse.result.maxBaseVol),
            orderType: 'maker',
            createdAt: setPriceResponse.result.createdAt,
          ),
        );
      }
    } catch (e) {
      yield* Stream.error(
        SwapException(
          'Swap failed: $e',
          SwapException.mapErrorToCode(e.toString()),
        ),
      );
    } finally {
      if (uuid != null) {
        await _activeSwaps[uuid]?.close();
        _activeSwaps.remove(uuid);
      }
    }
  }

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
  Future<Decimal> getMaxTradableVolume(String coin) async {
    try {
      await _ensureAssetsActivated([coin]);

      final response = await _client.rpc.swap.maxMakerVol(coin: coin);
      return Decimal.parse(response.volume.decimal);
    } catch (e) {
      throw SwapException(
        'Failed to get max tradable volume: $e',
        SwapException.mapErrorToCode(e.toString()),
      );
    }
  }

  /// Cancel all orders for a specific coin or all orders
  Future<bool> cancelAllOrders({String? coin}) async {
    try {
      final cancelBy =
          coin != null
              ? CancelByCoin(data: CancelByCoinData(ticker: coin))
              : const CancelByAll();

      final response = await _client.rpc.swap.cancelAllOrdersLegacy(
        cancelBy: cancelBy,
      );

      return response.result.cancelled.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _ensureAssetsActivated(List<String> assetIds) async {
    for (final assetId in assetIds) {
      final assets = _assetProvider.findAssetsByConfigId(assetId);
      if (assets.isEmpty) {
        throw SwapException(
          'Asset $assetId not found',
          SwapErrorCode.assetNotActivated,
        );
      }

      final asset = assets.first;
      final activationStatus =
          await _activationManager.activateAsset(asset).last;

      if (activationStatus.isComplete && !activationStatus.isSuccess) {
        throw SwapException(
          'Failed to activate asset $assetId',
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
