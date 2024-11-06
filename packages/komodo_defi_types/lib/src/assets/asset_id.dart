import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';
import 'package:komodo_defi_types/types.dart';

class AssetId extends Equatable {
  const AssetId({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
    required this.derivationPath,
    // required this.children,
    this.parentId,
  });

  factory AssetId.fromConfig(JsonMap json, {Map<String, AssetId>? knownIds}) {
    final parentCoin = json.valueOrNull<String>('parent_coin');

    return AssetId(
      id: json.value<String>('coin'),
      name: json.value<String>('fname'),
      symbol: AssetSymbol.fromConfig(json),
      chainId: ChainId.parse(json),
      derivationPath: json.valueOrNull<String>('derivation_path'),
      parentId:
          parentCoin != null && knownIds != null ? knownIds[parentCoin] : null,
    );
  }

  final String id;
  final String name;
  final AssetSymbol symbol;
  final ChainId chainId;
  final String? derivationPath;
  final AssetId? parentId;

  // final Set<AssetId> children;

  bool get isChildAsset => parentId != null;
  // bool get isPlatformAsset => parentId == null;

  JsonMap toJson() {
    return {
      'coin': id,
      'fname': name,
      'symbol': symbol.toJson(),
      'chain_id': chainId.formattedChainId,
      'derivation_path': derivationPath,
      if (parentId != null) 'parent_coin': parentId!.id,
    };
  }

  @override
  List<Object?> get props => [
        id,
        // name, symbol, chainId, derivationPath, parentId
      ];

  bool isSameAsset(AssetId other) {
    return id == other.id &&
        chainId.formattedChainId == other.chainId.formattedChainId;
  }

  @override
  String toString() =>
      'AssetId(id: $id${parentId != null ? ', parent: ${parentId!.id}' : ''})';
}

abstract class ChainId with EquatableMixin {
  // const ChainId.fromConfig();

  static ChainId parse(JsonMap json) {
    final chainParseAttempts = [
      () => parseOrNull(() => AssetChainId.fromConfig(json)),
      () => parseOrNull(() => TendermintChainId.fromConfig(json)),
      () => ProtocolChainId.fromConfig(json),
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

  static ChainId? parseOrNull(
    ChainId? Function() fromConfig,
  ) {
    try {
      return fromConfig();
    } catch (e) {
      return null;
    }
  }
}

class AssetChainId extends ChainId {
  AssetChainId({
    required this.chainId,
  });

  @override
  factory AssetChainId.fromConfig(JsonMap json) {
    return AssetChainId(
      chainId: json.value<int>('chain_id'),
    );
  }
  final int chainId;

  @override
  String get formattedChainId => chainId.toString();

  @override
  List<Object?> get props => [chainId];
}

class TendermintChainId extends ChainId {
  TendermintChainId({
    required this.accountPrefix,
    required this.chainId,
    required this.chainRegistryName,
  });

  @override
  factory TendermintChainId.fromConfig(JsonMap json) {
    final protocolData = json.value<JsonMap>('protocol', 'protocol_data');
    return TendermintChainId(
      accountPrefix: protocolData.value<String>('account_prefix'),
      chainId: protocolData.value<String>('chain_id'),
      chainRegistryName: protocolData.value<String>('chain_registry_name'),
    );
  }

  final String accountPrefix;
  final String chainId;
  final String chainRegistryName;

  @override
  String get formattedChainId => '$chainRegistryName:$chainId';

  @override
  List<Object?> get props => [accountPrefix, chainId, chainRegistryName];
}

class ProtocolChainId extends ChainId {
  ProtocolChainId({
    required ProtocolClass protocol,
  }) : _protocol = protocol;

  @override
  factory ProtocolChainId.fromConfig(JsonMap json) {
    final protocol = ProtocolClass.fromJson(json);
    return ProtocolChainId(
      protocol: protocol,
    );
  }

  final ProtocolClass _protocol;

  @override
  String get formattedChainId => _protocol.runtimeType.toString();

  @override
  List<Object?> get props => [_protocol];
}
