import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';

class AssetId extends Equatable {
  const AssetId({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
    required this.derivationPath,
    required this.subClass,
    this.parentId,
  });

  factory AssetId.parse(JsonMap json, {required Set<AssetId>? knownIds}) {
    final subClass = CoinSubClass.parse(json.value('type'));

    final parentCoinTicker = json.valueOrNull<String>('parent_coin');
    final maybeParent = parentCoinTicker == null
        ? null
        : knownIds?.singleWhere(
            (parent) =>
                parent.id == parentCoinTicker && parent.subClass == subClass,
          );

    return AssetId(
      id: json.value<String>('coin'),
      name: json.value<String>('fname'),
      symbol: AssetSymbol.fromConfig(json),
      chainId: ChainId.parse(json),
      derivationPath: json.valueOrNull<String>('derivation_path'),
      subClass: subClass,
      parentId: maybeParent,
    );
  }

  final String id;
  final String name;
  final AssetSymbol symbol;
  final ChainId chainId;
  final String? derivationPath;
  final CoinSubClass subClass;
  final AssetId? parentId;

  // TODO? Revisit how Segwit is handled in KW and SDK, and make necessary
  // changes if needed
  bool get isSegwit => id.toLowerCase().contains('segwit');

  bool get isChildAsset => parentId != null;

  AssetId copyWith({
    String? id,
    String? name,
    AssetSymbol? symbol,
    ChainId? chainId,
    String? derivationPath,
    CoinSubClass? subClass,
    AssetId? parentId,
  }) {
    return AssetId(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      chainId: chainId ?? this.chainId,
      derivationPath: derivationPath ?? this.derivationPath,
      subClass: subClass ?? this.subClass,
      parentId: parentId ?? this.parentId,
    );
  }

  /// Method that parses a config object and returns a set of [AssetId] objects.
  ///
  /// For most coins, this will return a single [AssetId] object. However, for
  /// coins that have `other_types` defined in the config, this will return
  /// multiple [AssetId] objects.
  static Set<AssetId> parseAllTypes(
    JsonMap json, {
    required Set<AssetId>? knownIds,
  }) {
    final assetIds = {AssetId.parse(json, knownIds: knownIds)};

    return assetIds;

    // Remove below if it is confirmed that we will never encounter a coin with
    // multiple types which need to be treated as separate assets. This was
    // possible in the past with SLP coins, but they have been deprecated.

    final otherTypes = json.valueOrNull<List<String>>('other_types') ?? [];

    for (final otherType in otherTypes) {
      final jsonCopy = JsonMap.from(json);
      final otherTypesCopy = List<String>.from(otherTypes)
        ..remove(otherType)
        ..add(json.value('type'));

      // TODO: Perhaps restructure so we can copy the protocol data from
      // another coin with the same type
      if (otherType == 'UTXO') {
        // remove all fields except for protocol->type from the protocol data
        jsonCopy['protocol'] = {'type': otherType};
      }

      jsonCopy['type'] = otherType;
      jsonCopy['other_types'] = otherTypesCopy;

      // assetIds.add(AssetId.parse(jsonCopy));
    }

    return assetIds;
  }

  // // Used for string representation in maps/logs
  // String get uniqueId => isChildAsset
  //     ? '${parentId!.id}/${id}_${subClass.formatted}'
  //     : '${id}_${subClass.formatted}';

  JsonMap toJson() => {
        'coin': id,
        'fname': name,
        'symbol': symbol.toJson(),
        'chain_id': chainId.formattedChainId,
        'derivation_path': derivationPath,
        'type': subClass.formatted,
        if (parentId != null) 'parent_coin': parentId!.id,
      };

  @override
  List<Object?> get props => [id, subClass.formatted];

  @override
  String toString() =>
      '${isChildAsset ? "${parentId!.id}/" : ""}$id (${subClass.formatted})';

  bool isSameAsset(AssetId other) {
    return id == other.id &&
        subClass == other.subClass &&
        chainId.formattedChainId == other.chainId.formattedChainId;
  }
}

abstract class ChainId with EquatableMixin {
  static ChainId parse(JsonMap json) {
    final chainParseAttempts = [
      () => parseOrNull(() => AssetChainId.fromConfig(json)),
      () => parseOrNull(() => TendermintChainId.fromConfig(json)),
      () => parseOrNull(() => ProtocolChainId.fromConfig(json)),
    ];

    for (final parseAttempt in chainParseAttempts) {
      final chainId = parseAttempt();
      if (chainId != null) {
        return chainId;
      }
    }

    throw Exception('Unsupported chain ID type');
  }

  String get formattedChainId;
  int? get decimals;

  static ChainId? parseOrNull(ChainId? Function() fromConfig) {
    try {
      return fromConfig();
    } catch (e) {
      return null;
    }
  }
}

class AssetChainId extends ChainId {
  AssetChainId({required this.chainId, this.decimalsValue});

  @override
  factory AssetChainId.fromConfig(JsonMap json) {
    return AssetChainId(
      chainId: json.value<int>('chain_id'),
      decimalsValue: json.valueOrNull<int>('decimals'),
    );
  }

  final int chainId;
  final int? decimalsValue;

  @override
  String get formattedChainId => chainId.toString();

  @override
  int? get decimals => decimalsValue;

  @override
  List<Object?> get props => [chainId, decimalsValue];
}

class TendermintChainId extends ChainId {
  TendermintChainId({
    required this.accountPrefix,
    required this.chainId,
    required this.chainRegistryName,
    this.decimalsValue,
  });

  @override
  factory TendermintChainId.fromConfig(JsonMap json) {
    final protocolData = json.value<JsonMap>('protocol', 'protocol_data');
    return TendermintChainId(
      accountPrefix: protocolData.value<String>('account_prefix'),
      chainId: protocolData.value<String>('chain_id'),
      chainRegistryName: protocolData.value<String>('chain_registry_name'),
      decimalsValue: protocolData.valueOrNull<int>('decimals') ??
          json.valueOrNull<int>('decimals'),
    );
  }

  final String accountPrefix;
  final String chainId;
  final String chainRegistryName;
  final int? decimalsValue;

  @override
  String get formattedChainId => '$chainRegistryName:$chainId';

  @override
  int? get decimals => decimalsValue;

  @override
  List<Object?> get props => [
        accountPrefix,
        chainId,
        chainRegistryName,
        decimalsValue,
      ];
}

class ProtocolChainId extends ChainId {
  ProtocolChainId({required ProtocolClass protocol, this.decimalsValue})
      : _protocol = protocol;

  @override
  factory ProtocolChainId.fromConfig(JsonMap json) {
    final protocol = ProtocolClass.fromJson(json);
    return ProtocolChainId(
      protocol: protocol,
      decimalsValue: json.valueOrNull<int>('decimals'),
    );
  }

  final ProtocolClass _protocol;
  final int? decimalsValue;

  @override
  String get formattedChainId => _protocol.runtimeType.toString();

  @override
  int? get decimals => decimalsValue;

  @override
  List<Object?> get props => [_protocol, decimalsValue];
}
