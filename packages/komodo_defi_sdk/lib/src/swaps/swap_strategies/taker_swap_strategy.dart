import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'swap_strategy.dart';

/// Strategy that places a taker order and fails if it doesn't succeed
class TakerSwapStrategy extends BaseSwapStrategy {
  /// Creates a new taker swap strategy
  const TakerSwapStrategy();

  @override
  String get name => 'Taker';

  @override
  String get description => 
      'Places a taker order immediately and fails if it cannot match';

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
        message: 'Initializing taker swap...',
      );

      yield const SwapProgress(
        status: SwapStatus.placingTakerOrder,
        message: 'Placing taker order...',
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
