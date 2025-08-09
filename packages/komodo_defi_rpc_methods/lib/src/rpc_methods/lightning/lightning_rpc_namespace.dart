import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Extensions for Lightning Network-related RPC methods
class LightningMethodsNamespace extends BaseRpcMethodNamespace {
  LightningMethodsNamespace(super.client);

  /// Initialize Lightning Network for a coin
  Future<EnableLightningResponse> enableLightning({
    required String ticker,
    required LightningActivationParams activationParams,
    String? rpcPass,
  }) {
    return execute(
      EnableLightningRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        ticker: ticker,
        activationParams: activationParams,
      ),
    );
  }

  /// Get Lightning channels information
  Future<GetChannelsResponse> getChannels({
    required String coin,
    LightningOpenChannelsFilter? openFilter,
    LightningClosedChannelsFilter? closedFilter,
    String? rpcPass,
  }) {
    return execute(
      GetChannelsRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        openFilter: openFilter,
        closedFilter: closedFilter,
      ),
    );
  }

  /// Open a Lightning channel
  Future<OpenChannelResponse> openChannel({
    required String coin,
    required String nodeId,
    required int amountSat,
    LightningChannelOptions? options,
    String? rpcPass,
  }) {
    return execute(
      OpenChannelRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        nodeId: nodeId,
        amountSat: amountSat,
        options: options,
      ),
    );
  }

  /// Close a Lightning channel
  Future<CloseChannelResponse> closeChannel({
    required String coin,
    required String channelId,
    bool forceClose = false,
    String? rpcPass,
  }) {
    return execute(
      CloseChannelRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        channelId: channelId,
        forceClose: forceClose,
      ),
    );
  }

  /// Generate a Lightning invoice
  Future<GenerateInvoiceResponse> generateInvoice({
    required String coin,
    required int amountMsat,
    required String description,
    int? expiry,
    String? rpcPass,
  }) {
    return execute(
      GenerateInvoiceRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        amountMsat: amountMsat,
        description: description,
        expiry: expiry,
      ),
    );
  }

  /// Pay a Lightning invoice
  Future<PayInvoiceResponse> payInvoice({
    required String coin,
    required String invoice,
    int? maxFeeMsat,
    String? rpcPass,
  }) {
    return execute(
      PayInvoiceRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        invoice: invoice,
        maxFeeMsat: maxFeeMsat,
      ),
    );
  }

  /// Get Lightning payment history
  Future<GetPaymentHistoryResponse> getPaymentHistory({
    required String coin,
    LightningPaymentFilter? filter,
    Pagination? pagination,
    String? rpcPass,
  }) {
    return execute(
      GetPaymentHistoryRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        filter: filter,
        pagination: pagination,
      ),
    );
  }
}