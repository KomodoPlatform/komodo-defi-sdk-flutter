import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

abstract class Chain {
  const Chain({
    required this.id,
    required this.name,
    required this.symbol,
    required this.decimals,
    // required this.enableRequest,
    required this.isHdWalletSupported,
    // required this.createEnableRequest,
  });

  final String id;
  final String name;
  final String symbol;
  final int decimals;
  final bool isHdWalletSupported;

  BaseRequest createEnableRequest(ActivationParams params);
  // final BaseRequest enableRequest;

  Chain fromJsonConfig(JsonMap json);
}

// !????
abstract class SupportsHdWallet {}
