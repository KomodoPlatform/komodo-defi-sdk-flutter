// ignore_for_file: avoid_unused_constructor_parameters

import 'package:komodo_defi_types/src/utils/json_type_utils.dart';
import 'package:komodo_defi_types/types.dart';

// Updated Protocol Class without direct dependency on strategies
abstract class ProtocolClass {
  ProtocolClass(this.subClass, this.activationStrategy, this._originalJson);
  final ActivationStrategy activationStrategy;
  final CoinSubClass subClass;

  final JsonMap _originalJson;

  JsonMap toJson() => _originalJson;

  static ProtocolClass fromJson(JsonMap json) {
    return ProtocolFactory.fromJson(json);
  }

  static ProtocolClass? tryParse(JsonMap json) {
    try {
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }
}

class ProtocolFactory {
  // TODO: Refactor to be able to parse un-supported protocols so they can
  // still be shown in the UI.
  static ProtocolClass fromJson(JsonMap json) {
    final subClass = CoinSubClass.tryParse(json.value<String>('type'));
    final protocolClass = json.value<String?>('protocol', 'type');

    if (subClass == null || protocolClass == null || protocolClass != 'UTXO') {
      throw Exception('Unsupported protocol type: $protocolClass');
    }

    final activationStrategy =
        ActivationStrategyFactory.fromJsonConfig(subClass, json);

    switch (subClass) {
      case CoinSubClass.utxo:
      case CoinSubClass.smartChain:
        return UtxoProtocol(subClass, activationStrategy, json);
      // Handle other cases similarly
      default:
        throw ArgumentError(
            'Unknown or unsupported protocol type: ${json['type']}');
    }
  }
}

class UtxoProtocol extends ProtocolClass {
  UtxoProtocol(super.subClass, super.activationStrategy, super._originalJson);
}

class SlpProtocol extends ProtocolClass {
  SlpProtocol(super.subClass, super.activationStrategy, super._originalJson);
}

class QtumProtocol extends ProtocolClass {
  QtumProtocol(super.subClass, super.activationStrategy, super._originalJson);
}

class Erc20Protocol extends ProtocolClass {
  Erc20Protocol(super.subClass, super.activationStrategy, super._originalJson);
}

class EthProtocol extends ProtocolClass {
  EthProtocol(super.subClass, super.activationStrategy, super._originalJson);
}

class ZhtlcProtocol extends ProtocolClass {
  ZhtlcProtocol(super.subClass, super.activationStrategy, super._originalJson);
}



// UtxoProtocol example (other protocols follow similar pattern)

// Base protocol class
// sealed class ProtocolClass /*with EquatableMixin*/ {
//   ProtocolClass(this.subClass, this.activationStrategy);



//   // Todo: ...?
//   static ProtocolClass fromJson(JsonMap json) {
//     final subClass = CoinSubClass.tryParse(json.value<String>('type'));
//     final protocolClass = json.value<String?>('protocol', 'type');

//     if (subClass == null || protocolClass == null || protocolClass != 'UTXO') {
//       throw Exception('Unsupported protocol type: $protocolClass');
//     }

//     // final activationStrategy = createActivationStrategy(subClass, json);

//     return UtxoProtocol(subClass, UtxoActivationStrategy.fromJsonConfig(json));

//     switch (subClass) {
//       case CoinSubClass.utxo:
//       case CoinSubClass.smartChain:
//         return UtxoProtocol(
//           subClass,
//           UtxoActivationStrategy.fromJsonConfig(json),
//         );
//       // TODO!        //
//       // case CoinSubClass.erc20:
//       //   return Erc20Protocol(subClass, ActivationStrategy..
//       // case CoinSubClass.eth:
//       //   return EthProtocol(subClass, activationStrategy);
//       // // Add other cases as needed for other CoinSubClasses
//       default:
//         throw ArgumentError(
//           'Unknown or unsupported protocol type: ${json['type']}',
//         );
//     }
//   }

//   final ActivationStrategy activationStrategy;
//   final CoinSubClass subClass;
// }

// class UtxoProtocol extends ProtocolClass {
//   UtxoProtocol(super.subClass, super.activationStrategy);

//   factory UtxoProtocol.fromJson(JsonMap json) {
//     return ProtocolClass.fromJson(json) as UtxoProtocol;
//   }
// }

// class SlpProtocol extends ProtocolClass {
//   SlpProtocol(super.subClass, super.activationStrategy);

//   factory SlpProtocol.fromJson(JsonMap json) {
//     throw UnimplementedError();
//     // TODO! Implement pro
//     return ProtocolClass.fromJson(json) as SlpProtocol;
//   }
// }

// class QtumProtocol extends ProtocolClass {
//   QtumProtocol(super.subClass, super.activationStrategy);

//   factory QtumProtocol.fromJson(JsonMap json) {
//     final subClass = CoinSubClass.parse(json.value<String>('type'));
//     final activationStrategy = PlaceholderStrategy(); //TODO!
//     return QtumProtocol(subClass, activationStrategy);
//   }
// }

// class Erc20Protocol extends ProtocolClass {
//   Erc20Protocol(super.subClass, super.activationStrategy);

//   factory Erc20Protocol.fromJson(JsonMap json) {
//     const subClass = CoinSubClass.erc20;
//     final activationStrategy = PlaceholderStrategy(); //TODO!
//     return Erc20Protocol(subClass, activationStrategy);
//   }
// }

// class EthProtocol extends ProtocolClass {
//   EthProtocol(super.subClass, super.activationStrategy);

//   factory EthProtocol.fromJson(CoinSubClass subClass, JsonMap json) {
//     // final subClass = CoinSubClass.eth;
//     final activationStrategy = PlaceholderStrategy(); //TODO!
//     return EthProtocol(subClass, activationStrategy);
//   }
// }

// // ActivationStrategy createActivationStrategy(
// //     CoinSubClass subClass, JsonMap json) {
// // final protocol =
// //   }
// // }
