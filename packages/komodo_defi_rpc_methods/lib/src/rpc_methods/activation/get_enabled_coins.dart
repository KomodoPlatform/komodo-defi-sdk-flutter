// lib/src/rpc_methods/get_enabled_coins.dart

// import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class GetEnabledCoinsRequest
    extends BaseRequest<GetEnabledCoinsResponse, GeneralErrorResponse> {
  GetEnabledCoinsRequest({super.rpcPass})
    : super(method: 'get_enabled_coins', mmrpc: '2.0');

  @override
  GetEnabledCoinsResponse parseResponse(String responseBody) {
    return GetEnabledCoinsResponse.fromJson(jsonFromString(responseBody));
  }
}

class GetEnabledCoinsResponse extends BaseResponse {
  GetEnabledCoinsResponse({required super.mmrpc, required this.result});

  factory GetEnabledCoinsResponse.fromJson(Map<String, dynamic> json) {
    return GetEnabledCoinsResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result:
          json
              .value<JsonList>('result', 'coins')
              .map(EnabledCoinInfo.fromJson)
              .toList(),
    );
  }

  final List<EnabledCoinInfo> result;

  @override
  Map<String, dynamic> toJson() => {
    'result': result.map((e) => e.toJson()).toList(),
  };
}

// TODO? Move to common structures?

class EnabledCoinInfo {
  EnabledCoinInfo({required this.ticker});

  factory EnabledCoinInfo.fromJson(Map<String, dynamic> json) {
    return EnabledCoinInfo(ticker: json.value<String>('ticker'));
  }

  final String ticker;

  Map<String, dynamic> toJson() => {'ticker': ticker};
}
