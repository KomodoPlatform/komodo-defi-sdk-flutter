import 'package:komodo_defi_types/komodo_defi_types.dart';

class AddressFormat {
  const AddressFormat({
    required this.format,
    required this.network,
  });

  factory AddressFormat.fromCoinSubClass(
    CoinSubClass subClass, {
    bool isBchNetwork = false,
  }) {
    switch (subClass) {
      case CoinSubClass.erc20:
        return AddressFormat(
          format: AddressFormatFormat.mixedCase.toString(),
          network: '',
        );
      case CoinSubClass.qrc20:
        return AddressFormat(
          format: AddressFormatFormat.contract.toString(),
          network: '',
        );
      case CoinSubClass.utxo:
      // The only explicitly defined coins are ETH, UTXO and QTUM, and the
      // behaviour previously was to use cashaddress as the default
      // unless the coin was ERC20.
      // ignore: no_default_cases
      default:
        return AddressFormat(
          format: AddressFormatFormat.cashAddress.toString(),
          // Only set network for BCH coins
          network:
              isBchNetwork ? AddressFormatNetwork.bitcoinCash.toString() : '',
        );
    }
  }

  final String format;
  final String network;

  Map<String, dynamic> toJson() => {
        'format': format,
        'network': network,
      };
}

/// [AddressFormat] format field options.
enum AddressFormatFormat {
  /// Use for ETH, ERC20 coins
  mixedCase,

  /// Use [cashAddress] OR [standard] for UTXO coins
  cashAddress,

  /// Use [cashAddress] OR [standard] for UTXO coins
  standard,

  /// Use [contract] or [wallet] for QTUM and QRC20 coins
  contract,

  /// Use [contract] or [wallet] for QTUM and QRC20 coins
  wallet;

  @override
  String toString() {
    switch (this) {
      case AddressFormatFormat.mixedCase:
        return 'mixedcase';
      case AddressFormatFormat.cashAddress:
        return 'cashaddress';
      case AddressFormatFormat.standard:
        return 'standard';
      case AddressFormatFormat.contract:
        return 'contract';
      case AddressFormatFormat.wallet:
        return 'wallet';
    }
  }
}

/// [AddressFormat] network prefix for [AddressFormatFormat.cashAddress]
/// format. Used only for UTXO coins, specifically BCH at the moment.
enum AddressFormatNetwork {
  /// BCH main network (mainnet)
  bitcoinCash,

  /// BCH test network (testnet)
  bchTest,

  /// BCH regtest
  bchReg;

  @override
  String toString() {
    switch (this) {
      case AddressFormatNetwork.bitcoinCash:
        return 'bitcoincash';
      case AddressFormatNetwork.bchTest:
        return 'bchtest';
      case AddressFormatNetwork.bchReg:
        return 'bchreg';
    }
  }
}
