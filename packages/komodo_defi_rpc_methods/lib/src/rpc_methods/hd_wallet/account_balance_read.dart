import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

/// Reads existing HD addresses without creating accounts or scanning new ones.
class AccountBalanceReadRequest
    extends BaseRequest<AccountBalanceReadResponse, GeneralErrorResponse> {
  AccountBalanceReadRequest({
    required this.coin,
    required this.accountIndex,
    this.chain = 'External',
    this.page = 1,
    super.rpcPass,
  }) : super(method: 'account_balance', mmrpc: RpcVersion.v2_0);

  final String coin;
  final int accountIndex;
  final String chain;
  final int page;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'coin': coin,
      'account_index': accountIndex,
      'chain': chain,
      'limit': 100,
      'paging_options': {'PageNumber': page},
    },
  };

  @override
  AccountBalanceReadResponse parse(Map<String, dynamic> json) {
    try {
      final result = json['result'] as Map<String, dynamic>;
      final addresses = (result['addresses'] as List<dynamic>).map((item) {
        final address = item as Map<String, dynamic>;
        return ExportAddressMetadata(
          address: address['address'] as String,
          derivationPath: address['derivation_path'] as String,
          chain: address['chain'] as String,
        );
      }).toList();
      return AccountBalanceReadResponse(
        mmrpc: json['mmrpc'] as String?,
        accountIndex: result['account_index'] as int,
        totalPages: result['total_pages'] as int,
        addresses: addresses,
      );
    } catch (_) {
      throw const FormatException('Invalid account balance metadata');
    }
  }
}

class ExportAddressMetadata {
  const ExportAddressMetadata({
    required this.address,
    required this.derivationPath,
    required this.chain,
  });

  final String address;
  final String derivationPath;
  final String chain;

  Map<String, dynamic> toJson() => {
    'address': address,
    'derivation_path': derivationPath,
    'chain': chain,
  };

  @override
  String toString() => 'ExportAddressMetadata(redacted)';
}

class AccountBalanceReadResponse extends BaseResponse {
  AccountBalanceReadResponse({
    required super.mmrpc,
    required this.accountIndex,
    required this.totalPages,
    required this.addresses,
  });

  final int accountIndex;
  final int totalPages;
  final List<ExportAddressMetadata> addresses;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'account_index': accountIndex,
      'total_pages': totalPages,
      'addresses': addresses.map((address) => address.toJson()).toList(),
    },
  };

  @override
  String toString() => 'AccountBalanceReadResponse(redacted)';
}
