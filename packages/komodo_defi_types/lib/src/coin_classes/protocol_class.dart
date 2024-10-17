// ignore_for_file: avoid_unused_constructor_parameters

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/src/utils/json_type_utils.dart';
import 'package:komodo_defi_types/types.dart';

// Base protocol class
sealed class ProtocolClass /*with EquatableMixin*/ {
  ProtocolClass(this.subClass, this.activationStrategy);

  static ProtocolClass? tryParse(JsonMap json) {
    try {
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // Todo: ...?
  static ProtocolClass fromJson(JsonMap json) {
    final subClass = CoinSubClass.tryParse(json.value<String>('type'));
    final protocolClass = json.value<String?>('protocol', 'type');

    if (subClass == null || protocolClass == null || protocolClass != 'UTXO') {
      throw Exception('Unsupported protocol type: $protocolClass');
    }

    // final activationStrategy = createActivationStrategy(subClass, json);

    return UtxoProtocol(subClass, UtxoActivationStrategy.fromJsonConfig(json));

    switch (subClass) {
      case CoinSubClass.utxo:
      case CoinSubClass.smartChain:
        return UtxoProtocol(
          subClass,
          UtxoActivationStrategy.fromJsonConfig(json),
        );
      // TODO!        //
      // case CoinSubClass.erc20:
      //   return Erc20Protocol(subClass, ActivationStrategy..
      // case CoinSubClass.eth:
      //   return EthProtocol(subClass, activationStrategy);
      // // Add other cases as needed for other CoinSubClasses
      default:
        throw ArgumentError(
          'Unknown or unsupported protocol type: ${json['type']}',
        );
    }
  }

  final ActivationStrategy activationStrategy;
  final CoinSubClass subClass;
}

class UtxoProtocol extends ProtocolClass {
  UtxoProtocol(super.subClass, super.activationStrategy);

  factory UtxoProtocol.fromJson(JsonMap json) {
    return ProtocolClass.fromJson(json) as UtxoProtocol;
  }
}

class QtumProtocol extends ProtocolClass {
  QtumProtocol(super.subClass, super.activationStrategy);

  factory QtumProtocol.fromJson(JsonMap json) {
    final subClass = CoinSubClass.parse(json.value<String>('type'));
    final activationStrategy = PlaceholderStrategy(); //TODO!
    return QtumProtocol(subClass, activationStrategy);
  }
}

class Erc20Protocol extends ProtocolClass {
  Erc20Protocol(super.subClass, super.activationStrategy);

  factory Erc20Protocol.fromJson(JsonMap json) {
    const subClass = CoinSubClass.erc20;
    final activationStrategy = PlaceholderStrategy(); //TODO!
    return Erc20Protocol(subClass, activationStrategy);
  }
}

class EthProtocol extends ProtocolClass {
  EthProtocol(super.subClass, super.activationStrategy);

  factory EthProtocol.fromJson(CoinSubClass subClass, JsonMap json) {
    // final subClass = CoinSubClass.eth;
    final activationStrategy = PlaceholderStrategy(); //TODO!
    return EthProtocol(subClass, activationStrategy);
  }
}

// ActivationStrategy createActivationStrategy(
//     CoinSubClass subClass, JsonMap json) {
// final protocol =
//   }
// }
