import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

@Deprecated('Use V2 GetEnabledCoinsRequest')
class LegacyGetEnabledCoinsRequest
    extends BaseRequest<LegacyGetEnabledCoinsResponse, GeneralErrorResponse> {
  @Deprecated('Use V2 GetEnabledCoinsRequest')
  LegacyGetEnabledCoinsRequest({super.rpcPass})
      : super(method: 'get_enabled_coins', mmrpc: null);

  @override
  LegacyGetEnabledCoinsResponse parseResponse(String responseBody) {
    return LegacyGetEnabledCoinsResponse.fromJson(jsonFromString(responseBody));
  }
}

class LegacyGetEnabledCoinsResponse extends BaseResponse {
  LegacyGetEnabledCoinsResponse({
    required super.mmrpc,
    required this.result,
  });

  factory LegacyGetEnabledCoinsResponse.fromJson(Map<String, dynamic> json) {
    return LegacyGetEnabledCoinsResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result: json
          .value<JsonList>('result')
          .map(LegacyEnabledCoinInfo.fromJson)
          .toList(),
    );
  }

  final List<LegacyEnabledCoinInfo> result;

  @override
  Map<String, dynamic> toJson() => {
        'result': result.map((e) => e.toJson()).toList(),
      };
}

class LegacyEnabledCoinInfo {
  LegacyEnabledCoinInfo({
    required this.address,
    required this.ticker,
  });

  factory LegacyEnabledCoinInfo.fromJson(Map<String, dynamic> json) {
    return LegacyEnabledCoinInfo(
      address: json.value<String>('address'),
      ticker: json.value<String>('ticker'),
    );
  }

  final String address;
  final String ticker;

  Map<String, dynamic> toJson() => {
        'address': address,
        'ticker': ticker,
      };
}
