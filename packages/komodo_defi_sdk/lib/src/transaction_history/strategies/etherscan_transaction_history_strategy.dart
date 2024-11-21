import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
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
  bool supportsAsset(Asset asset) =>
      _protocolHelper.supportsProtocol(asset.protocol);

  @override
  Future<MyTxHistoryResponse> fetchTransactionHistory(
    ApiClient client,
    Asset asset,
    TransactionPagination pagination,
  ) async {
    validatePagination(pagination);

    final url = _protocolHelper.getApiUrlForAsset(asset);
    if (url == null) {
      throw UnsupportedError(
        'Asset ${asset.id.name} is not supported by EtherscanTransactionStrategy',
      );
    }

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
                ? WithdrawFee.fromJson(
                    tx.value<JsonMap>('fee_details')
                      ..setIfAbsentOrEmpty('type', 'Eth'),
                  )
                : null,
            coin: coinId,
            internalId: tx.value<String>('internal_id'),
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
  bool supportsProtocol(ProtocolClass protocol) {
    return protocol is Erc20Protocol ||
        protocol.subClass == CoinSubClass.utxo || // For parent chains
        _getBaseEndpoint(protocol.subClass) != null;
  }

  /// Constructs the appropriate API URL for a given asset
  Uri? getApiUrlForAsset(Asset asset) {
    if (!supportsProtocol(asset.protocol)) return null;

    final endpoint = _getEndpointForAsset(asset);
    if (endpoint == null) return null;

    return Uri.parse('$_baseUrl$endpoint');
  }

  String? _getEndpointForAsset(Asset asset) {
    final version = _getApiVersion(asset);
    final baseEndpoint = _getBaseEndpoint(asset.protocol.subClass);
    if (baseEndpoint == null) return null;

    final parentPrefix = baseEndpoint.split('_').first;
    final isParentChain = asset.id.parentId == null;

    if (isParentChain) {
      return '/v$version/${parentPrefix}_tx_history';
    }

    // For tokens, we need contract address in the path
    if (asset.protocol is! Erc20Protocol) {
      return null;
    }

    final protocol = asset.protocol as Erc20Protocol;
    return '/v$version/$baseEndpoint/${protocol.swapContractAddress}';
  }

  int _getApiVersion(Asset asset) {
    // Parent chains (ETH, BNB etc) use v1, tokens use v2
    return asset.id.parentId == null ? 1 : 2;
  }

  String? _getBaseEndpoint(CoinSubClass subClass) {
    return switch (subClass) {
      CoinSubClass.erc20 => 'eth_tx_history',
      CoinSubClass.bep20 => 'bep_tx_history',
      CoinSubClass.matic => 'plg_tx_history',
      CoinSubClass.ftm20 => 'ftm_tx_history',
      CoinSubClass.avx20 => 'avx_tx_history',
      CoinSubClass.moonriver => 'moonriver_tx_history',
      CoinSubClass.moonbeam => 'moonbeam_tx_history',
      CoinSubClass.ethereumClassic => 'etc_tx_history',
      CoinSubClass.hecoChain => 'heco_tx_history',
      CoinSubClass.krc20 => 'kcs_tx_history',
      _ => null,
    };
  }

  /// Get an appropriate human-readable name for a given protocol
  String getProtocolDisplayName(Asset asset) {
    return switch (asset.protocol.subClass) {
      CoinSubClass.erc20 => 'Ethereum',
      CoinSubClass.bep20 => 'Binance Smart Chain',
      CoinSubClass.matic => 'Polygon',
      CoinSubClass.ftm20 => 'Fantom',
      CoinSubClass.avx20 => 'Avalanche',
      CoinSubClass.moonriver => 'Moonriver',
      CoinSubClass.moonbeam => 'Moonbeam',
      CoinSubClass.ethereumClassic => 'Ethereum Classic',
      CoinSubClass.hecoChain => 'HECO Chain',
      CoinSubClass.krc20 => 'KuCoin Chain',
      _ => 'Unknown Chain',
    };
  }
}
