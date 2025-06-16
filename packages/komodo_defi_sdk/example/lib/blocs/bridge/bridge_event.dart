part of 'bridge_bloc.dart';

abstract class BridgeEvent extends Equatable {
  const BridgeEvent();

  @override
  List<Object?> get props => [];
}

class BridgeInit extends BridgeEvent {
  const BridgeInit({required this.ticker});

  final String ticker;

  @override
  List<Object?> get props => [ticker];
}

class BridgeTickerChanged extends BridgeEvent {
  const BridgeTickerChanged(this.ticker);

  final String? ticker;

  @override
  List<Object?> get props => [ticker];
}

class BridgeShowTickerDropdown extends BridgeEvent {
  const BridgeShowTickerDropdown(this.show);

  final bool show;

  @override
  List<Object?> get props => [show];
}

class BridgeShowSourceDropdown extends BridgeEvent {
  const BridgeShowSourceDropdown(this.show);

  final bool show;

  @override
  List<Object?> get props => [show];
}

class BridgeShowTargetDropdown extends BridgeEvent {
  const BridgeShowTargetDropdown(this.show);

  final bool show;

  @override
  List<Object?> get props => [show];
}

class BridgeSetSellAsset extends BridgeEvent {
  const BridgeSetSellAsset(this.asset);

  final Asset asset;

  @override
  List<Object?> get props => [asset];
}

class BridgeSelectBestOrder extends BridgeEvent {
  const BridgeSelectBestOrder(this.order);

  final OrderData? order;

  @override
  List<Object?> get props => [order];
}

class BridgeSetError extends BridgeEvent {
  const BridgeSetError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class BridgeClearErrors extends BridgeEvent {
  const BridgeClearErrors();
}

class BridgeSetSellAmount extends BridgeEvent {
  const BridgeSetSellAmount(this.amount);

  final Decimal? amount;

  @override
  List<Object?> get props => [amount];
}

class BridgeSellAmountChanged extends BridgeEvent {
  const BridgeSellAmountChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class BridgeAmountButtonClicked extends BridgeEvent {
  const BridgeAmountButtonClicked(this.fraction);

  final double fraction;

  @override
  List<Object?> get props => [fraction];
}

class BridgeSubmitClicked extends BridgeEvent {
  const BridgeSubmitClicked();
}

class BridgeBackClicked extends BridgeEvent {
  const BridgeBackClicked();
}

class BridgeStartSwap extends BridgeEvent {
  const BridgeStartSwap();
}

class BridgeClear extends BridgeEvent {
  const BridgeClear();
}
