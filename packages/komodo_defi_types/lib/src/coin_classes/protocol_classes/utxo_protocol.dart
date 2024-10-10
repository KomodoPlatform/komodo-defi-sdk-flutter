import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
// import 'package:types_library/types_library.dart'; // Assuming the types library has ActivationStrategy

// class UtxoProtocol extends ProtocolClass {
//   UtxoProtocol({
//     required ActivationStrategy activationStrategy,
//     required this.bip44,
//   }) : super(CoinSubClass.utxo, activationStrategy);

//   factory UtxoProtocol.fromJsonConfig(Map<String, dynamic> json) {
//     final bip44 = json.value<String>('bip44');
//     final activationStrategy = UtxoActivationStrategy.fromJsonConfig(json);

//     return UtxoProtocol(
//       activationStrategy: activationStrategy,
//       bip44: bip44,
//     );
//   }

//   final String bip44;
// }


// class UTXOProtocol extends ProtocolClass {
//   final String ticker;
//   final int pubtype;
//   final int p2shtype;
//   final int wiftype;
//   final int txVersion;
//   final int txFee;
//   final int gapLimit;
//   final bool overwintered;

//   UTXOProtocol({
//     required this.ticker,
//     required this.pubtype,
//     required this.p2shtype,
//     required this.wiftype,
//     required this.txVersion,
//     required this.txFee,
//     required this.gapLimit,
//     required this.overwintered,
//     required ActivationStrategy activationStrategy,
//   }) : super(
//           subClass: CoinSubClass.utxo,
//           activationStrategy: activationStrategy,
//         );

//   /// Converts the protocol details to a JSON representation
//   Map<String, dynamic> toJson() => {
//         'ticker': ticker,
//         'pubtype': pubtype,
//         'p2shtype': p2shtype,
//         'wiftype': wiftype,
//         'txversion': txVersion,
//         'txfee': txFee,
//         'gap_limit': gapLimit,
//         'overwintered': overwintered,
//       };
// }
