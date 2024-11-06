enum CoinSubClass {
  moonbeam,
  ftm20,
  arbitrum,
  slp,
  qrc20,
  avx20,
  smartChain,
  moonriver,
  ethereumClassic,
  tendermintToken,
  ubiq,
  bep20,
  matic,
  utxo,
  smartBch,
  erc20,
  tendermint,
  krc20,
  ewt,
  hrc20,
  hecoChain,
  rskSmartBitcoin,
  zhtlc,
  unknown;

  // Parse
  static CoinSubClass parse(String value) {
    const filteredChars = ['_', '-', ' '];
    final regex = RegExp('(${filteredChars.join('|')})');

    final sanitizedValue = value.toLowerCase().replaceAll(regex, '');

    return CoinSubClass.values.firstWhere(
      (e) => e.toString().toLowerCase().contains(sanitizedValue),
      // orElse: () => CoinSubClass.unknown,
    );

    switch (sanitizedValue) {
      case 'smartbch':
        return CoinSubClass.smartBch;
      case 'erc20':
        return CoinSubClass.erc20;
      case 'moonbeam':
        return CoinSubClass.moonbeam;
      case 'ftm20':
        return CoinSubClass.ftm20;
      case 'arbitrum':
        return CoinSubClass.arbitrum;
      case 'slp':
        return CoinSubClass.slp;
      case 'qrc20':
        return CoinSubClass.qrc20;
      case 'avx20':
        return CoinSubClass.avx20;
      case 'smartchain':
        return CoinSubClass.smartChain;
      case 'moonriver':
        return CoinSubClass.moonriver;
      case 'ethereumclassic':
        return CoinSubClass.ethereumClassic;
      case 'tenderminttoken':
        return CoinSubClass.tendermintToken;
      case 'ubiq':
        return CoinSubClass.ubiq;
      case 'bep20':
        return CoinSubClass.bep20;
      case 'matic':
        return CoinSubClass.matic;
      case 'utxo':
        return CoinSubClass.utxo;
      default:
        throw ArgumentError('Unknown/unsupported CoinSubClass: $value');
    }
  }

  static CoinSubClass? tryParse(String value) {
    try {
      return parse(value);
    } catch (_) {
      return null;
    }
  }

  // TODO: Consider if null or an empty string should be returned for
  // subclasses where they don't have a symbol used in coin IDs.
  String get formatted {
    switch (this) {
      case CoinSubClass.moonbeam:
        return 'Moonbeam';
      case CoinSubClass.ftm20:
        return 'FTM20';
      case CoinSubClass.arbitrum:
        return 'Arbitrum';
      case CoinSubClass.slp:
        return 'SLP';
      case CoinSubClass.qrc20:
        return 'QRC20';
      case CoinSubClass.avx20:
        return 'AVX20';
      case CoinSubClass.smartChain:
        return 'Smart Chain';
      case CoinSubClass.moonriver:
        return 'Moonriver';
      case CoinSubClass.ethereumClassic:
        return 'Ethereum Classic';
      case CoinSubClass.tendermintToken:
        return 'Tendermint Token';
      case CoinSubClass.ubiq:
        return 'Ubiq';
      case CoinSubClass.bep20:
        return 'BEP20';
      case CoinSubClass.matic:
        return 'Matic';
      case CoinSubClass.utxo:
        return 'UTXO';
      case CoinSubClass.smartBch:
        return 'SmartBCH';
      case CoinSubClass.erc20:
        return 'ERC20';
      case CoinSubClass.tendermint:
        return 'Tendermint';
      case CoinSubClass.krc20:
        return 'KRC20';
      case CoinSubClass.ewt:
        return 'EWT';
      case CoinSubClass.hrc20:
        return 'HRC20';
      case CoinSubClass.hecoChain:
        return 'Heco Chain';
      case CoinSubClass.rskSmartBitcoin:
        return 'RSK Smart Bitcoin';
      case CoinSubClass.zhtlc:
        return 'ZHTLC';
      case CoinSubClass.unknown:
        return 'Unknown';
    }
  }
}
