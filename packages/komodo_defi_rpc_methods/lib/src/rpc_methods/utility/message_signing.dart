import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to sign a message with a coin's signing key
class SignMessageRequest
    extends BaseRequest<SignMessageResponse, GeneralErrorResponse> {
  /// Creates a new request to sign a message
  ///
  /// [coin] - The coin to sign a message with
  /// [message] - The message you want to sign
  /// [addressPath] - Optional HD wallet address path (for HD wallets only)
  ///
  /// For non-HD wallets, omit the [addressPath] parameter.
  /// For HD wallets, provide an [AddressPath] using either:
  /// - `AddressPath.derivationPath("m/44'/141'/0'/0/0")`
  /// - `AddressPath.components(accountId: 0, chain: 'External', addressId: 0)`
  SignMessageRequest({
    required String rpcPass,
    required this.coin,
    required this.message,
    this.addressPath,
  }) : super(method: 'sign_message', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// The coin to sign a message with
  final String coin;

  /// The message you want to sign
  final String message;

  /// Optional HD address path selector
  ///
  /// For HD wallets only. If not provided, the root derivation path will be used.
  /// See [AddressPath] for more details.
  final AddressPath? addressPath;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{'coin': coin, 'message': message};

    // Add HD address path if provided
    if (addressPath != null) {
      params['address'] = addressPath!.toJson();
    }

    return super.toJson().deepMerge({'params': params});
  }

  @override
  SignMessageResponse parse(Map<String, dynamic> json) =>
      SignMessageResponse.parse(json);
}

/// Response from a sign message request
class SignMessageResponse extends BaseResponse {
  /// Creates a new sign message response
  SignMessageResponse({required super.mmrpc, required this.signature});

  /// Creates a new sign message response from JSON
  factory SignMessageResponse.parse(Map<String, dynamic> json) {
    return SignMessageResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      signature: json.value<JsonMap>('result').value<String>('signature'),
    );
  }

  /// The signature generated for the message
  final String signature;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'signature': signature},
    };
  }
}

/// Request to verify a message signature
class VerifyMessageRequest
    extends BaseRequest<VerifyMessageResponse, GeneralErrorResponse> {
  /// Creates a new request to verify a message
  VerifyMessageRequest({
    required String rpcPass,
    required this.coin,
    required this.message,
    required this.signature,
    required this.address,
  }) : super(
         method: 'verify_message',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// The coin to verify a message with
  final String coin;

  /// The message input via the `sign_message` method sign
  final String message;

  /// The signature generated for the message
  final String signature;

  /// The address used to sign the message
  final String address;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'coin': coin,
        'message': message,
        'signature': signature,
        'address': address,
      },
    });
  }

  @override
  VerifyMessageResponse parse(Map<String, dynamic> json) =>
      VerifyMessageResponse.parse(json);
}

/// Response from a verify message request
class VerifyMessageResponse extends BaseResponse {
  /// Creates a new verify message response
  VerifyMessageResponse({required super.mmrpc, required this.isValid});

  /// Creates a new verify message response from JSON
  factory VerifyMessageResponse.parse(Map<String, dynamic> json) {
    return VerifyMessageResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      isValid: json.value<JsonMap>('result').value<bool>('is_valid'),
    );
  }

  /// Whether the message signature is valid
  final bool isValid;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'is_valid': isValid},
    };
  }
}
