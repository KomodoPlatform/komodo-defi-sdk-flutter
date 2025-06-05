import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class AddressMethodsNamespace extends BaseRpcMethodNamespace {
  AddressMethodsNamespace(super.client);

  /// Convert an address from one format to another
  Future<ConvertAddressResponse> convertAddress({
    required String coin,
    required String from,
    required AddressFormat toFormat,
  }) {
    return execute(
      ConvertAddressRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        fromAddress: from,
        toAddressFormat: toFormat,
      ),
    );
  }

  /// Convert a UTXO address to another UTXO coin's address format
  Future<ConvertUtxoAddressResponse> convertUtxoAddress({
    required String coin,
    required String address,
    required String toCoin,
  }) {
    return execute(
      ConvertUtxoAddressRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        address: address,
        toCoin: toCoin,
      ),
    );
  }

  /// Validate if an address is valid for a given coin
  Future<ValidateAddressResponse> validateAddress({
    required String coin,
    required String address,
  }) {
    return execute(
      ValidateAddressRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        address: address,
      ),
    );
  }
}
