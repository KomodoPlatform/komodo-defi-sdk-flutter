import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    hide SwapStatus;
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy that checks the orderbook and decides whether to act as taker or maker
class SmartSwapStrategy extends BaseSwapStrategy {
  /// Creates a new smart swap strategy
  const SmartSwapStrategy();

  @override
  String get name => 'Smart';

  @override
  String get description =>
      'Checks orderbook for matching orders and acts as taker if found, otherwise as maker';

  @override
  Stream<SwapProgress> execute(
    SwapParameters parameters,
    ApiClient client,
    IAssetProvider assetProvider,
    ActivationManager activationManager,
    Map<String, StreamController<SwapProgress>> activeSwaps,
  ) async* {
    StreamController<SwapProgress>? controller;
    String? uuid;

    try {
      // Ensure both assets are activated
      await ensureAssetsActivated(
        [parameters.base, parameters.rel],
        assetProvider,
        activationManager,
      );

      yield const SwapProgress(
        status: SwapStatus.initializing,
        message: 'Initializing smart swap...',
      );

      // Check for existing orders using bestOrders
      yield const SwapProgress(
        status: SwapStatus.searchingForOrders,
        message: 'Searching for matching orders...',
      );

      final bestOrders = await client.rpc.swap.bestOrders(
        coin: parameters.base.id,
        action: 'sell',
        requestBy: RequestByVolume(value: parameters.volume.toDouble()),
        excludeMine: true,
      );

      // If there are matching orders, act as taker
      if (bestOrders.orders.isNotEmpty) {
        yield const SwapProgress(
          status: SwapStatus.placingTakerOrder,
          message: 'Matching orders found. Placing taker order...',
        );

        final sellResponse = await client.rpc.swap.sellLegacy(
          base: parameters.base.id,
          rel: parameters.rel.id,
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
        activeSwaps[uuid] = controller;

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
          message: 'Taker swap completed successfully',
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

        final setPriceResponse = await client.rpc.swap.setPriceLegacy(
          base: parameters.base.id,
          rel: parameters.rel.id,
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
        activeSwaps[uuid] = controller;

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
      yield* handleError(e);
    } finally {
      if (uuid != null) {
        await activeSwaps[uuid]?.close();
        activeSwaps.remove(uuid);
      }
    }
  }
}
