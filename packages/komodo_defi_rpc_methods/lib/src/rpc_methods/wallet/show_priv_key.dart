import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Exports the signing key selected when [coin] was activated.
///
/// This legacy RPC cannot select an HD path or export an address range.
class ShowPrivKeyRequest
    extends BaseRequest<ShowPrivKeyResponse, GeneralErrorResponse> {
  ShowPrivKeyRequest({required this.coin, super.rpcPass})
    : super(method: 'show_priv_key', mmrpc: null) {
    if (coin.trim().isEmpty) {
      throw ArgumentError('show_priv_key requires a nonempty coin');
    }
  }

  final String coin;

  @override
  JsonMap toJson() => {...super.toJson(), 'coin': coin};

  @override
  ShowPrivKeyResponse parse(JsonMap json) {
    final response = ShowPrivKeyResponse.parse(json);
    if (response.coin != coin) {
      throw const FormatException('show_priv_key returned a different coin');
    }
    return response;
  }

  @override
  String toString() => 'ShowPrivKeyRequest([REDACTED])';
}

/// An activated coin's signing key. [toJson] deliberately contains the secret
/// for explicit export; diagnostics must use the redacted [toString] instead.
class ShowPrivKeyResponse extends BaseResponse {
  ShowPrivKeyResponse({
    required this.coin,
    required this.privKey,
    super.mmrpc,
  }) {
    if (coin.trim().isEmpty || privKey.trim().isEmpty) {
      throw const FormatException('Invalid show_priv_key result');
    }
  }

  factory ShowPrivKeyResponse.parse(JsonMap json) {
    final result = json['result'];
    final mmrpc = json['mmrpc'];
    if (result is! JsonMap || (mmrpc != null && mmrpc is! String)) {
      throw const FormatException('Invalid show_priv_key response');
    }
    final coin = result['coin'];
    final privKey = result['priv_key'];
    if (coin is! String || privKey is! String) {
      // Never include the input or value in a parser error: this envelope
      // contains secret key material even when another field is malformed.
      throw const FormatException('Invalid show_priv_key result');
    }
    return ShowPrivKeyResponse(
      coin: coin,
      privKey: privKey,
      mmrpc: mmrpc as String?,
    );
  }

  final String coin;
  final String privKey;

  @override
  JsonMap toJson() => {
    if (mmrpc != null) 'mmrpc': mmrpc,
    'result': {'coin': coin, 'priv_key': privKey},
  };

  @override
  String toString() => 'ShowPrivKeyResponse([REDACTED])';
}
