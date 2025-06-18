import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'swap_execution_event.dart';
part 'swap_execution_state.dart';

class SwapExecutionBloc extends Bloc<SwapExecutionEvent, SwapExecutionState> {
  SwapExecutionBloc(this._sdk) : super(const SwapExecutionState()) {
    on<SellAssetSelected>(_onSellAssetSelected);
    on<BuyAssetSelected>(_onBuyAssetSelected);
    on<VolumeChanged>(_onVolumeChanged);
    on<PriceChanged>(_onPriceChanged);
    on<PreviewSwapRequested>(_onPreviewSwapRequested);
    on<SwapRequested>(_onSwapRequested);
    on<SwapCancelRequested>(_onSwapCancelRequested);
    on<SwapProgressUpdated>(_onSwapProgressUpdated);
    on<ResetSwap>(_onResetSwap);
  }

  final KomodoDefiSdk _sdk;
  StreamSubscription<SwapProgress>? _swapSubscription;

  @override
  Future<void> close() {
    _swapSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSellAssetSelected(
    SellAssetSelected event,
    Emitter<SwapExecutionState> emit,
  ) async {
    emit(
      state.copyWith(sellAsset: event.asset, swapPreview: null, error: null),
    );
  }

  Future<void> _onBuyAssetSelected(
    BuyAssetSelected event,
    Emitter<SwapExecutionState> emit,
  ) async {
    emit(state.copyWith(buyAsset: event.asset, swapPreview: null, error: null));
  }

  Future<void> _onVolumeChanged(
    VolumeChanged event,
    Emitter<SwapExecutionState> emit,
  ) async {
    emit(state.copyWith(volume: event.volume, swapPreview: null));
  }

  Future<void> _onPriceChanged(
    PriceChanged event,
    Emitter<SwapExecutionState> emit,
  ) async {
    emit(state.copyWith(price: event.price, swapPreview: null));
  }

  Future<void> _onPreviewSwapRequested(
    PreviewSwapRequested event,
    Emitter<SwapExecutionState> emit,
  ) async {
    final sellAsset = state.sellAsset;
    final buyAsset = state.buyAsset;
    final volume = state.volume;
    final price = state.price;

    if (sellAsset == null ||
        buyAsset == null ||
        volume == null ||
        price == null) {
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(state.copyWith(isLoadingPreview: true, error: null));

    try {
      final parameters = SwapParameters(
        base: buyAsset.id,
        rel: sellAsset.id,
        price: price,
        volume: volume,
      );

      final preview = await _sdk.swaps.previewSwap(parameters);
      emit(state.copyWith(swapPreview: preview, isLoadingPreview: false));
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to preview swap: $e',
          isLoadingPreview: false,
        ),
      );
    }
  }

  Future<void> _onSwapRequested(
    SwapRequested event,
    Emitter<SwapExecutionState> emit,
  ) async {
    final sellAsset = state.sellAsset;
    final buyAsset = state.buyAsset;
    final volume = state.volume;
    final price = state.price;

    if (sellAsset == null ||
        buyAsset == null ||
        volume == null ||
        price == null) {
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(state.copyWith(isSwapping: true, swapProgress: null, error: null));

    try {
      final parameters = SwapParameters(
        base: buyAsset.id,
        rel: sellAsset.id,
        price: price,
        volume: volume,
      );

      // Cancel any existing swap subscription
      await _swapSubscription?.cancel();

      // Start the swap with default smart strategy
      _swapSubscription = _sdk.swaps.swap(parameters).listen(
        (progress) => add(SwapProgressUpdated(progress)),
        onError: (Object error) => add(
          SwapProgressUpdated(
            SwapProgress(
              status: SwapStatus.error,
              message: 'Swap failed: $error',
              errorMessage: error.toString(),
            ),
          ),
        ),
        onDone: () {
          // Swap completed or cancelled
        },
      );
    } catch (e) {
      emit(
        state.copyWith(error: 'Failed to start swap: $e', isSwapping: false),
      );
    }
  }

  Future<void> _onSwapCancelRequested(
    SwapCancelRequested event,
    Emitter<SwapExecutionState> emit,
  ) async {
    final currentProgress = state.swapProgress;
    if (currentProgress?.uuid != null) {
      try {
        await _sdk.swaps.cancelSwap(currentProgress!.uuid!);
        emit(state.copyWith(isSwapping: false, swapProgress: null));
      } catch (e) {
        emit(state.copyWith(error: 'Failed to cancel swap: $e'));
      }
    }

    // Cancel the subscription regardless
    await _swapSubscription?.cancel();
    _swapSubscription = null;
  }

  void _onSwapProgressUpdated(
    SwapProgressUpdated event,
    Emitter<SwapExecutionState> emit,
  ) {
    final progress = event.progress;

    emit(
      state.copyWith(
        swapProgress: progress,
        isSwapping: progress.status != SwapStatus.complete &&
            progress.status != SwapStatus.error,
        error: progress.errorMessage,
      ),
    );

    // If swap is completed or failed, clean up subscription
    if (progress.status == SwapStatus.complete ||
        progress.status == SwapStatus.error) {
      _swapSubscription?.cancel();
      _swapSubscription = null;
    }
  }

  void _onResetSwap(ResetSwap event, Emitter<SwapExecutionState> emit) {
    _swapSubscription?.cancel();
    _swapSubscription = null;

    emit(
      state.copyWith(
        swapProgress: null,
        swapPreview: null,
        isSwapping: false,
        isLoadingPreview: false,
        error: null,
      ),
    );
  }
}
