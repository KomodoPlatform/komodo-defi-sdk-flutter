import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy for fetching transaction history from the Etherscan proxy service.
/// Handles pagination client-side since the API currently doesn't support it.
class EtherscanTransactionStrategy extends TransactionHistoryStrategy {
  EtherscanTransactionStrategy({
    http.Client? httpClient,
    String? baseUrl,
  })  : _client = httpClient ?? http.Client(),
        _protocolHelper = EtherscanProtocolHelper(baseUrl: baseUrl);

  final http.Client _client;
  final EtherscanProtocolHelper _protocolHelper;

  @override
  Set<Type> get supportedPaginationModes => {
        PagePagination,
        TransactionBasedPagination,
      };

  @override
  bool supportsAsset(Asset asset) => _protocolHelper.supportsProtocol(asset);

  @override
  Future<MyTxHistoryResponse> fetchTransactionHistory(
    ApiClient client,
    Asset asset,
    TransactionPagination pagination,
  ) async {
    if (!supportsAsset(asset)) {
      throw UnsupportedError(
        'Asset ${asset.id.name} is not supported by EtherscanTransactionStrategy',
      );
    }

    // TODO! Remove after resolving tx history spamming issue in KW.
    if (kDebugMode) {
      return MyTxHistoryResponse.empty();
    }

    validatePagination(pagination);

    final url = _protocolHelper.getApiUrlForAsset(asset) ??
        (throw UnsupportedError(
          'No API URL found for asset ${asset.id.toJson()}',
        ));

    try {
      final addresses = await _getAssetPubkeys(asset);
      final allTransactions = <TransactionInfo>[];

      // Fetch transactions for each address
      for (final address in addresses) {
        final uri = url.replace(
          pathSegments: [...url.pathSegments, address.address],
          queryParameters:
              asset.protocol.isTestnet ? {'testnet': 'true'} : null,
        );
        // Add the address as the next path segment

        final response = await _executeRequest(uri);
        final transactions = _parseTransactions(response, asset.id.id);
        allTransactions.addAll(transactions);
      }

      // Sort by timestamp (newest first)
      allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination based on type
      final paginatedResults = switch (pagination) {
        final PagePagination p => _applyPagePagination(
            allTransactions,
            p.pageNumber,
            p.itemsPerPage,
          ),
        final TransactionBasedPagination t => _applyTransactionPagination(
            allTransactions,
            t.fromId,
            t.itemCount,
          ),
        _ => throw UnsupportedError(
            'Unsupported pagination type: ${pagination.runtimeType}',
          ),
      };

      final currentBlock =
          allTransactions.isNotEmpty ? allTransactions.first.blockHeight : 0;

      return MyTxHistoryResponse(
        mmrpc: '2.0',
        currentBlock: currentBlock,
        fromId: paginatedResults.transactions.lastOrNull?.txHash,
        limit: paginatedResults.pageSize,
        skipped: paginatedResults.skipped,
        syncStatus: SyncStatusResponse(
          state: TransactionSyncStatusEnum.finished,
        ),
        total: allTransactions.length,
        totalPages: (allTransactions.length / paginatedResults.pageSize).ceil(),
        pageNumber: pagination is PagePagination ? pagination.pageNumber : null,
        transactions: paginatedResults.transactions,
      );
    } catch (e) {
      throw HttpException(
        'Error fetching transaction history: $e',
      );
    }
  }

  Future<List<PubkeyInfo>> _getAssetPubkeys(Asset asset) async {
    return (await KomodoDefiSdk.global.pubkeys.getPubkeys(asset)).keys;
  }

  Future<JsonMap> _executeRequest(Uri uri) async {
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch transaction history: ${response.statusCode}',
          uri: uri,
        );
      }

      return jsonFromString(response.body);
    } on http.ClientException catch (e) {
      throw HttpException(
        'Network error while fetching transaction history: ${e.message}',
        uri: uri,
      );
    }
  }

  List<TransactionInfo> _parseTransactions(JsonMap response, String coinId) {
    final result = response.value<JsonMap>('result');
    return result
        .value<JsonList>('transactions')
        .map(
          (tx) => TransactionInfo(
            txHash: tx.value<String>('tx_hash'),
            from: List<String>.from(tx.value('from')),
            to: List<String>.from(tx.value('to')),
            myBalanceChange: tx.value<String>('my_balance_change'),
            blockHeight: tx.value<int>('block_height'),
            confirmations: tx.value<int>('confirmations'),
            timestamp: tx.value<int>('timestamp'),
            feeDetails: tx.valueOrNull<JsonMap>('fee_details') != null
                ? FeeInfo.fromJson(
                    tx.value<JsonMap>('fee_details')
                      ..setIfAbsentOrEmpty('type', 'Eth'),
                  )
                : null,
            coin: coinId,
            internalId: tx.value<String>('internal_id'),
            memo: tx.valueOrNull<String>('memo'),
          ),
        )
        .toList();
  }

  ({
    List<TransactionInfo> transactions,
    int skipped,
    int pageSize,
  }) _applyPagePagination(
    List<TransactionInfo> transactions,
    int pageNumber,
    int itemsPerPage,
  ) {
    final startIndex = (pageNumber - 1) * itemsPerPage;
    return (
      transactions: transactions.skip(startIndex).take(itemsPerPage).toList(),
      skipped: startIndex,
      pageSize: itemsPerPage,
    );
  }

  ({
    List<TransactionInfo> transactions,
    int skipped,
    int pageSize,
  }) _applyTransactionPagination(
    List<TransactionInfo> transactions,
    String fromId,
    int itemCount,
  ) {
    final startIndex = transactions.indexWhere((tx) => tx.txHash == fromId);
    if (startIndex == -1) {
      return (transactions: [], skipped: 0, pageSize: itemCount);
    }

    return (
      transactions: transactions.skip(startIndex + 1).take(itemCount).toList(),
      skipped: startIndex + 1,
      pageSize: itemCount,
    );
  }

  void dispose() {
    _client.close();
  }
}

/// Helper class for managing Etherscan protocol endpoints and URL construction
class EtherscanProtocolHelper {
  const EtherscanProtocolHelper({
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? 'https://etherscan-proxy.komodo.earth/api';

  final String _baseUrl;

  /// Returns true if the given protocol is supported by Etherscan
  bool supportsProtocol(Asset asset) {
    return asset.protocol is Erc20Protocol && getApiUrlForAsset(asset) != null;
  }

  /// Constructs the appropriate API URL for a given asset
  Uri? getApiUrlForAsset(Asset asset) {
    if (!supportsProtocol(asset)) return null;

    final endpoint = _getEndpointForAsset(asset);
    if (endpoint == null) return null;

    return Uri.parse(endpoint);
  }

  String? _getEndpointForAsset(Asset asset) {
    final baseEndpoint = _getBaseEndpoint(asset.id);
    if (baseEndpoint == null) return null;

    final isParentChain = asset.id.parentId == null;

    if (isParentChain) {
      return baseEndpoint;
    }

    // For tokens, we need contract address in the path
    if (asset.protocol is! Erc20Protocol) {
      return null;
    }

    final protocol = asset.protocol as Erc20Protocol;
    return '$baseEndpoint/${protocol.swapContractAddress}';
  }

  String? _getBaseEndpoint(AssetId id) {
    final isParentChain = id.parentId == null;
    return switch (id.subClass) {
      CoinSubClass.hecoChain when isParentChain => _hecoUrl,
      CoinSubClass.hecoChain => _hecoTokenUrl,
      CoinSubClass.bep20 when isParentChain => _bnbUrl,
      CoinSubClass.bep20 => _bepUrl,
      CoinSubClass.matic when isParentChain => _maticUrl,
      CoinSubClass.matic => _maticTokenUrl,
      CoinSubClass.ftm20 when isParentChain => _ftmUrl,
      CoinSubClass.ftm20 => _ftmTokenUrl,
      CoinSubClass.avx20 when isParentChain => _avaxUrl,
      CoinSubClass.avx20 => _avaxTokenUrl,
      CoinSubClass.moonriver when isParentChain => _mvrUrl,
      CoinSubClass.moonriver => _mvrTokenUrl,
      CoinSubClass.moonbeam => _arbUrl,
      CoinSubClass.ethereumClassic => _etcUrl,
      CoinSubClass.krc20 when isParentChain => _kcsUrl,
      CoinSubClass.krc20 => _kcsTokenUrl,
      CoinSubClass.erc20 when isParentChain => _ethUrl,
      CoinSubClass.erc20 => _ercUrl,
      CoinSubClass.arbitrum when isParentChain => _arbUrl,
      CoinSubClass.arbitrum => _arbTokenUrl,
      _ => null,
    };
  }

  /// Get an appropriate human-readable name for a given protocol
  String getProtocolDisplayName(Asset asset) {
    return asset.protocol.subClass.formatted;
  }

  String get _ethUrl => '$_baseUrl/v1/eth_tx_history';
  String get _ercUrl => '$_baseUrl/v2/erc_tx_history';
  String get _bnbUrl => '$_baseUrl/v1/bnb_tx_history';
  String get _bepUrl => '$_baseUrl/v2/bep_tx_history';
  String get _ftmUrl => '$_baseUrl/v1/ftm_tx_history';
  String get _ftmTokenUrl => '$_baseUrl/v2/ftm_tx_history';
  String get _arbUrl => '$_baseUrl/v1/arbitrum_tx_history';
  String get _arbTokenUrl => '$_baseUrl/v2/arbitrum_tx_history';
  String get _etcUrl => '$_baseUrl/v1/etc_tx_history';
  String get _avaxUrl => '$_baseUrl/v1/avx_tx_history';
  String get _avaxTokenUrl => '$_baseUrl/v2/avx_tx_history';
  String get _mvrUrl => '$_baseUrl/v1/moonriver_tx_history';
  String get _mvrTokenUrl => '$_baseUrl/v2/moonriver_tx_history';
  String get _hecoUrl => '$_baseUrl/v1/heco_tx_history';
  String get _hecoTokenUrl => '$_baseUrl/v2/heco_tx_history';
  String get _maticUrl => '$_baseUrl/v1/plg_tx_history';
  String get _maticTokenUrl => '$_baseUrl/v2/plg_tx_history';
  String get _kcsUrl => '$_baseUrl/v1/kcs_tx_history';
  String get _kcsTokenUrl => '$_baseUrl/v2/kcs_tx_history';
  String get _txByHashUrl => '$_baseUrl/v1/transactions_by_hash';
}
