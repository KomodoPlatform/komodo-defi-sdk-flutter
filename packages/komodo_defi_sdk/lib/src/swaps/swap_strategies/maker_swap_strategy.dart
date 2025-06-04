import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy that places a maker order and returns the UUID
class MakerSwapStrategy extends BaseSwapStrategy {
  /// Creates a new maker swap strategy
  const MakerSwapStrategy();

  @override
  String get name => 'Maker';

  @override
  String get description => 
      'Places a maker order and waits for it to be matched';

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
        message: 'Initializing maker swap...',
      );

      yield const SwapProgress(
        status: SwapStatus.placingMakerOrder,
        message: 'Placing maker order...',
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
