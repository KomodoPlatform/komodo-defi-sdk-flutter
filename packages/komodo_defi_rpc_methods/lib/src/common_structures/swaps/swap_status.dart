import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Represents a fee structure for trading
class TradeFee {
  TradeFee({
    required this.coin,
    required this.amount,
    required this.paidFromTradingVol,
  });

  factory TradeFee.parse(Map<String, dynamic> json) {
    return TradeFee(
      coin: json.value<String>('coin'),
      amount: json.value<String>('amount'),
      paidFromTradingVol: json.value<bool>('paid_from_trading_vol'),
    );
  }

  final String coin;
  final String amount;
  final bool paidFromTradingVol;

  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'amount': amount,
      'paid_from_trading_vol': paidFromTradingVol,
    };
  }
}

/// Represents transaction data
class TransactionData {
  TransactionData({
    required this.txHex,
    required this.txHash,
  });

  factory TransactionData.parse(Map<String, dynamic> json) {
    return TransactionData(
      txHex: json.value<String>('tx_hex'),
      txHash: json.value<String>('tx_hash'),
    );
  }

  final String txHex;
  final String txHash;

  Map<String, dynamic> toJson() {
    return {
      'tx_hex': txHex,
      'tx_hash': txHash,
    };
  }
}

/// Represents swap event data
class SwapEventData {
  SwapEventData({
    this.takerCoin,
    this.makerCoin,
    this.maker,
    this.taker,
    this.myPersistentPub,
    this.lockDuration,
    this.makerAmount,
    this.takerAmount,
    this.makerPaymentConfirmations,
    this.makerPaymentRequiresNota,
    this.takerPaymentConfirmations,
    this.takerPaymentRequiresNota,
    this.takerPaymentLock,
    this.makerPaymentLock,
    this.uuid,
    this.startedAt,
    this.makerPaymentWait,
    this.makerCoinStartBlock,
    this.takerCoinStartBlock,
    this.feeToSendTakerFee,
    this.takerPaymentTradeFee,
    this.makerPaymentSpendTradeFee,
    this.makerPaymentTradeFee,
    this.takerPaymentSpendTradeFee,
    this.makerCoinHtlcPubkey,
    this.takerCoinHtlcPubkey,
    this.p2pPrivkey,
    this.makerPaymentLocktime,
    this.takerPaymentLocktime,
    this.makerPubkey,
    this.takerPubkey,
    this.secretHash,
    this.secret,
    this.makerCoinSwapContractAddr,
    this.takerCoinSwapContractAddr,
    this.txHex,
    this.txHash,
    this.transaction,
    this.error,
    this.waitUntil,
  });

  factory SwapEventData.parse(Map<String, dynamic> json) {
    return SwapEventData(
      takerCoin: json.valueOrNull<String>('taker_coin'),
      makerCoin: json.valueOrNull<String>('maker_coin'),
      maker: json.valueOrNull<String>('maker'),
      taker: json.valueOrNull<String>('taker'),
      myPersistentPub: json.valueOrNull<String>('my_persistent_pub'),
      lockDuration: json.valueOrNull<int>('lock_duration'),
      makerAmount: json.valueOrNull<String>('maker_amount'),
      takerAmount: json.valueOrNull<String>('taker_amount'),
      makerPaymentConfirmations: json.valueOrNull<int>('maker_payment_confirmations'),
      makerPaymentRequiresNota: json.valueOrNull<bool>('maker_payment_requires_nota'),
      takerPaymentConfirmations: json.valueOrNull<int>('taker_payment_confirmations'),
      takerPaymentRequiresNota: json.valueOrNull<bool>('taker_payment_requires_nota'),
      takerPaymentLock: json.valueOrNull<int>('taker_payment_lock'),
      makerPaymentLock: json.valueOrNull<int>('maker_payment_lock'),
      uuid: json.valueOrNull<String>('uuid'),
      startedAt: json.valueOrNull<int>('started_at'),
      makerPaymentWait: json.valueOrNull<int>('maker_payment_wait'),
      makerCoinStartBlock: json.valueOrNull<int>('maker_coin_start_block'),
      takerCoinStartBlock: json.valueOrNull<int>('taker_coin_start_block'),
      feeToSendTakerFee: json.valueOrNull<JsonMap>('fee_to_send_taker_fee') != null
          ? TradeFee.parse(json.value<JsonMap>('fee_to_send_taker_fee'))
          : null,
      takerPaymentTradeFee: json.valueOrNull<JsonMap>('taker_payment_trade_fee') != null
          ? TradeFee.parse(json.value<JsonMap>('taker_payment_trade_fee'))
          : null,
      makerPaymentSpendTradeFee: json.valueOrNull<JsonMap>('maker_payment_spend_trade_fee') != null
          ? TradeFee.parse(json.value<JsonMap>('maker_payment_spend_trade_fee'))
          : null,
      makerPaymentTradeFee: json.valueOrNull<JsonMap>('maker_payment_trade_fee') != null
          ? TradeFee.parse(json.value<JsonMap>('maker_payment_trade_fee'))
          : null,
      takerPaymentSpendTradeFee: json.valueOrNull<JsonMap>('taker_payment_spend_trade_fee') != null
          ? TradeFee.parse(json.value<JsonMap>('taker_payment_spend_trade_fee'))
          : null,
      makerCoinHtlcPubkey: json.valueOrNull<String>('maker_coin_htlc_pubkey'),
      takerCoinHtlcPubkey: json.valueOrNull<String>('taker_coin_htlc_pubkey'),
      p2pPrivkey: json.valueOrNull<String>('p2p_privkey'),
      makerPaymentLocktime: json.valueOrNull<int>('maker_payment_locktime'),
      takerPaymentLocktime: json.valueOrNull<int>('taker_payment_locktime'),
      makerPubkey: json.valueOrNull<String>('maker_pubkey'),
      takerPubkey: json.valueOrNull<String>('taker_pubkey'),
      secretHash: json.valueOrNull<String>('secret_hash'),
      secret: json.valueOrNull<String>('secret'),
      makerCoinSwapContractAddr: json.valueOrNull<String>('maker_coin_swap_contract_addr'),
      takerCoinSwapContractAddr: json.valueOrNull<String>('taker_coin_swap_contract_addr'),
      txHex: json.valueOrNull<String>('tx_hex'),
      txHash: json.valueOrNull<String>('tx_hash'),
      transaction: json.valueOrNull<JsonMap>('transaction') != null
          ? TransactionData.parse(json.value<JsonMap>('transaction'))
          : null,
      error: json.valueOrNull<String>('error'),
      waitUntil: json.valueOrNull<int>('wait_until'),
    );
  }

  final String? takerCoin;
  final String? makerCoin;
  final String? maker;
  final String? taker;
  final String? myPersistentPub;
  final int? lockDuration;
  final String? makerAmount;
  final String? takerAmount;
  final int? makerPaymentConfirmations;
  final bool? makerPaymentRequiresNota;
  final int? takerPaymentConfirmations;
  final bool? takerPaymentRequiresNota;
  final int? takerPaymentLock;
  final int? makerPaymentLock;
  final String? uuid;
  final int? startedAt;
  final int? makerPaymentWait;
  final int? makerCoinStartBlock;
  final int? takerCoinStartBlock;
  final TradeFee? feeToSendTakerFee;
  final TradeFee? takerPaymentTradeFee;
  final TradeFee? makerPaymentSpendTradeFee;
  final TradeFee? makerPaymentTradeFee;
  final TradeFee? takerPaymentSpendTradeFee;
  final String? makerCoinHtlcPubkey;
  final String? takerCoinHtlcPubkey;
  final String? p2pPrivkey;
  final int? makerPaymentLocktime;
  final int? takerPaymentLocktime;
  final String? makerPubkey;
  final String? takerPubkey;
  final String? secretHash;
  final String? secret;
  final String? makerCoinSwapContractAddr;
  final String? takerCoinSwapContractAddr;
  final String? txHex;
  final String? txHash;
  final TransactionData? transaction;
  final String? error;
  final int? waitUntil;

  Map<String, dynamic> toJson() {
    return {
      if (takerCoin != null) 'taker_coin': takerCoin,
      if (makerCoin != null) 'maker_coin': makerCoin,
      if (maker != null) 'maker': maker,
      if (taker != null) 'taker': taker,
      if (myPersistentPub != null) 'my_persistent_pub': myPersistentPub,
      if (lockDuration != null) 'lock_duration': lockDuration,
      if (makerAmount != null) 'maker_amount': makerAmount,
      if (takerAmount != null) 'taker_amount': takerAmount,
      if (makerPaymentConfirmations != null) 'maker_payment_confirmations': makerPaymentConfirmations,
      if (makerPaymentRequiresNota != null) 'maker_payment_requires_nota': makerPaymentRequiresNota,
      if (takerPaymentConfirmations != null) 'taker_payment_confirmations': takerPaymentConfirmations,
      if (takerPaymentRequiresNota != null) 'taker_payment_requires_nota': takerPaymentRequiresNota,
      if (takerPaymentLock != null) 'taker_payment_lock': takerPaymentLock,
      if (makerPaymentLock != null) 'maker_payment_lock': makerPaymentLock,
      if (uuid != null) 'uuid': uuid,
      if (startedAt != null) 'started_at': startedAt,
      if (makerPaymentWait != null) 'maker_payment_wait': makerPaymentWait,
      if (makerCoinStartBlock != null) 'maker_coin_start_block': makerCoinStartBlock,
      if (takerCoinStartBlock != null) 'taker_coin_start_block': takerCoinStartBlock,
      if (feeToSendTakerFee != null) 'fee_to_send_taker_fee': feeToSendTakerFee!.toJson(),
      if (takerPaymentTradeFee != null) 'taker_payment_trade_fee': takerPaymentTradeFee!.toJson(),
      if (makerPaymentSpendTradeFee != null) 'maker_payment_spend_trade_fee': makerPaymentSpendTradeFee!.toJson(),
      if (makerPaymentTradeFee != null) 'maker_payment_trade_fee': makerPaymentTradeFee!.toJson(),
      if (takerPaymentSpendTradeFee != null) 'taker_payment_spend_trade_fee': takerPaymentSpendTradeFee!.toJson(),
      if (makerCoinHtlcPubkey != null) 'maker_coin_htlc_pubkey': makerCoinHtlcPubkey,
      if (takerCoinHtlcPubkey != null) 'taker_coin_htlc_pubkey': takerCoinHtlcPubkey,
      if (p2pPrivkey != null) 'p2p_privkey': p2pPrivkey,
      if (makerPaymentLocktime != null) 'maker_payment_locktime': makerPaymentLocktime,
      if (takerPaymentLocktime != null) 'taker_payment_locktime': takerPaymentLocktime,
      if (makerPubkey != null) 'maker_pubkey': makerPubkey,
      if (takerPubkey != null) 'taker_pubkey': takerPubkey,
      if (secretHash != null) 'secret_hash': secretHash,
      if (secret != null) 'secret': secret,
      if (makerCoinSwapContractAddr != null) 'maker_coin_swap_contract_addr': makerCoinSwapContractAddr,
      if (takerCoinSwapContractAddr != null) 'taker_coin_swap_contract_addr': takerCoinSwapContractAddr,
      if (txHex != null) 'tx_hex': txHex,
      if (txHash != null) 'tx_hash': txHash,
      if (transaction != null) 'transaction': transaction!.toJson(),
      if (error != null) 'error': error,
      if (waitUntil != null) 'wait_until': waitUntil,
    };
  }
}

/// Represents a swap event with timestamp and event data
class SwapEvent {
  SwapEvent({
    required this.timestamp,
    required this.event,
  });

  factory SwapEvent.parse(Map<String, dynamic> json) {
    final eventJson = json.value<JsonMap>('event');
    return SwapEvent(
      timestamp: json.value<int>('timestamp'),
      event: SwapEventInfo.parse(eventJson),
    );
  }

  final int timestamp;
  final SwapEventInfo event;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'event': event.toJson(),
    };
  }
}

/// Represents swap event information
class SwapEventInfo {
  SwapEventInfo({
    required this.type,
    this.data,
  });

  factory SwapEventInfo.parse(Map<String, dynamic> json) {
    return SwapEventInfo(
      type: json.value<String>('type'),
      data: json.valueOrNull<JsonMap>('data') != null
          ? SwapEventData.parse(json.value<JsonMap>('data'))
          : null,
    );
  }

  final String type;
  final SwapEventData? data;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

/// Represents swap information from user's perspective
class SwapMyInfo {
  SwapMyInfo({
    required this.myCoin,
    required this.otherCoin,
    required this.myAmount,
    required this.otherAmount,
    required this.startedAt,
  });

  factory SwapMyInfo.parse(Map<String, dynamic> json) {
    return SwapMyInfo(
      myCoin: json.value<String>('my_coin'),
      otherCoin: json.value<String>('other_coin'),
      myAmount: json.value<String>('my_amount'),
      otherAmount: json.value<String>('other_amount'),
      startedAt: json.value<int>('started_at'),
    );
  }

  final String myCoin;
  final String otherCoin;
  final String myAmount;
  final String otherAmount;
  final int startedAt;

  Map<String, dynamic> toJson() {
    return {
      'my_coin': myCoin,
      'other_coin': otherCoin,
      'my_amount': myAmount,
      'other_amount': otherAmount,
      'started_at': startedAt,
    };
  }
}

/// Represents the complete status of a swap
class SwapStatus {
  SwapStatus({
    required this.type,
    required this.uuid,
    required this.myOrderUuid,
    required this.events,
    required this.makerAmount,
    required this.makerCoin,
    required this.takerAmount,
    required this.takerCoin,
    required this.gui,
    required this.mmVersion,
    required this.successEvents,
    required this.errorEvents,
    this.makerCoinUsdPrice,
    this.takerCoinUsdPrice,
    this.myInfo,
    this.recoverable,
    this.isFinished,
  });

  factory SwapStatus.parse(Map<String, dynamic> json) {
    final eventsJson = json.value<List<dynamic>>('events');
    final events = eventsJson
        .map((e) => SwapEvent.parse(e as Map<String, dynamic>))
        .toList();

    final successEventsJson = json.value<List<dynamic>>('success_events');
    final successEvents = successEventsJson.cast<String>();

    final errorEventsJson = json.value<List<dynamic>>('error_events');
    final errorEvents = errorEventsJson.cast<String>();

    return SwapStatus(
      type: json.value<String>('type'),
      uuid: json.value<String>('uuid'),
      myOrderUuid: json.value<String>('my_order_uuid'),
      events: events,
      makerAmount: json.value<String>('maker_amount'),
      makerCoin: json.value<String>('maker_coin'),
      takerAmount: json.value<String>('taker_amount'),
      takerCoin: json.value<String>('taker_coin'),
      gui: json.value<String>('gui'),
      mmVersion: json.value<String>('mm_version'),
      successEvents: successEvents,
      errorEvents: errorEvents,
      makerCoinUsdPrice: json.valueOrNull<String>('maker_coin_usd_price'),
      takerCoinUsdPrice: json.valueOrNull<String>('taker_coin_usd_price'),
      myInfo: json.valueOrNull<JsonMap>('my_info') != null
          ? SwapMyInfo.parse(json.value<JsonMap>('my_info'))
          : null,
      recoverable: json.valueOrNull<bool>('recoverable'),
      isFinished: json.valueOrNull<bool>('is_finished'),
    );
  }

  final String type;
  final String uuid;
  final String myOrderUuid;
  final List<SwapEvent> events;
  final String makerAmount;
  final String makerCoin;
  final String takerAmount;
  final String takerCoin;
  final String gui;
  final String mmVersion;
  final List<String> successEvents;
  final List<String> errorEvents;
  final String? makerCoinUsdPrice;
  final String? takerCoinUsdPrice;
  final SwapMyInfo? myInfo;
  final bool? recoverable;
  final bool? isFinished;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'uuid': uuid,
      'my_order_uuid': myOrderUuid,
      'events': events.map((e) => e.toJson()).toList(),
      'maker_amount': makerAmount,
      'maker_coin': makerCoin,
      'taker_amount': takerAmount,
      'taker_coin': takerCoin,
      'gui': gui,
      'mm_version': mmVersion,
      'success_events': successEvents,
      'error_events': errorEvents,
      if (makerCoinUsdPrice != null) 'maker_coin_usd_price': makerCoinUsdPrice,
      if (takerCoinUsdPrice != null) 'taker_coin_usd_price': takerCoinUsdPrice,
      if (myInfo != null) 'my_info': myInfo!.toJson(),
      if (recoverable != null) 'recoverable': recoverable,
      if (isFinished != null) 'is_finished': isFinished,
    };
  }
}