import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// RPC namespace for Lightning Network operations.
///
/// This namespace provides methods for managing Lightning Network functionality
/// within the Komodo DeFi Framework. It includes operations for channel
/// management, payment processing, and Lightning Network node administration.
///
/// ## Key Features:
///
/// - **Channel Management**: Open, close, and monitor Lightning channels
/// - **Payment Operations**: Generate invoices and send payments
/// - **Network Participation**: Enable Lightning functionality for supported coins
///
/// ## Usage Example:
///
/// ```dart
/// final lightning = client.lightning;
///
/// // Enable Lightning for a coin
/// final response = await lightning.enableLightning(
///   ticker: 'BTC',
///   activationParams: LightningActivationParams(...),
/// );
///
/// // Open a channel
/// final channel = await lightning.openChannel(
///   coin: 'BTC',
///   nodeId: 'node_pubkey',
///   amountSat: 100000,
/// );
/// ```
class LightningMethodsNamespace extends BaseRpcMethodNamespace {
  /// Creates a new [LightningMethodsNamespace] instance.
  ///
  /// This is typically called internally by the [KomodoDefiRpcMethods] class.
  LightningMethodsNamespace(super.client);

  /// Enables Lightning Network functionality for a specific coin.
  ///
  /// This method initializes the Lightning Network daemon for the specified
  /// coin, setting up the necessary infrastructure for channel operations
  /// and payment processing.
  ///
  /// - [ticker]: The coin ticker to enable Lightning for (e.g., 'BTC')
  /// - [activationParams]: Configuration parameters for Lightning activation
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with an [EnableLightningResponse]
  /// containing the node ID and configuration details.
  ///
  /// Throws an exception if:
  /// - The coin doesn't support Lightning Network
  /// - Lightning is already enabled for the coin
  /// - Configuration parameters are invalid
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

  /// Retrieves information about Lightning channels.
  ///
  /// This method fetches detailed information about both open and closed
  /// Lightning channels for the specified coin. Filters can be applied
  /// to narrow down the results.
  ///
  /// - [coin]: The coin ticker to query channels for
  /// - [openFilter]: Optional filter for open channels
  /// - [closedFilter]: Optional filter for closed channels
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with a [GetChannelsResponse]
  /// containing lists of open and closed channels.
  ///
  /// Note: Only one filter (open or closed) can be applied at a time.
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

  /// Lists closed channels by optional filter.
  Future<ListClosedChannelsByFilterResponse> listClosedChannelsByFilter({
    required String coin,
    LightningClosedChannelsFilter? filter,
    String? rpcPass,
  }) {
    return execute(
      ListClosedChannelsByFilterRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        filter: filter,
      ),
    );
  }

  /// Gets a specific channel details by rpc_channel_id.
  Future<GetChannelDetailsResponse> getChannelDetails({
    required String coin,
    required int rpcChannelId,
    String? rpcPass,
  }) {
    return execute(
      GetChannelDetailsRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        rpcChannelId: rpcChannelId,
      ),
    );
  }

  /// Gets claimable balances (optionally including open channels balances).
  Future<GetClaimableBalancesResponse> getClaimableBalances({
    required String coin,
    bool? includeOpenChannelsBalances,
    String? rpcPass,
  }) {
    return execute(
      GetClaimableBalancesRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        includeOpenChannelsBalances: includeOpenChannelsBalances,
      ),
    );
  }

  /// Opens a new Lightning channel with a specified node.
  ///
  /// This method initiates the opening of a Lightning channel by creating
  /// an on-chain funding transaction. The channel becomes usable after
  /// sufficient blockchain confirmations.
  ///
  /// - [coin]: The coin ticker for the channel
  /// - [nodeId]: The public key of the node to open a channel with
  /// - [amountSat]: The channel capacity in satoshis
  /// - [options]: Optional channel configuration options
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with an [OpenChannelResponse]
  /// containing the channel ID and funding transaction details.
  ///
  /// Throws an exception if:
  /// - Insufficient balance for channel funding
  /// - Target node is unreachable
  /// - Channel amount is below minimum requirements
  Future<OpenChannelResponse> openChannel({
    required String coin,
    required String nodeAddress,
    required LightningChannelAmount amount,
    int? pushMsat,
    LightningChannelOptions? options,
    String? rpcPass,
  }) {
    return execute(
      OpenChannelRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        nodeAddress: nodeAddress,
        amount: amount,
        pushMsat: pushMsat,
        options: options,
      ),
    );
  }

  /// Closes an existing Lightning channel.
  ///
  /// This method initiates the closing of a Lightning channel. Channels
  /// can be closed cooperatively (mutual close) or unilaterally (force close).
  ///
  /// - [coin]: The coin ticker for the channel
  /// - [rpcChannelId]: The ID of the channel to close
  /// - [forceClose]: Whether to force close the channel unilaterally
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with a [CloseChannelResponse]
  /// containing the closing transaction details.
  ///
  /// Note: Force closing a channel may result in funds being locked
  /// for a timeout period and higher on-chain fees.
  Future<CloseChannelResponse> closeChannel({
    required String coin,
    required int rpcChannelId,
    bool forceClose = false,
    String? rpcPass,
  }) {
    return execute(
      CloseChannelRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        rpcChannelId: rpcChannelId,
        forceClose: forceClose,
      ),
    );
  }

  /// Generates a Lightning invoice for receiving payments.
  ///
  /// This method creates a BOLT 11 invoice that can be shared with
  /// payers to receive Lightning payments.
  ///
  /// - [coin]: The coin ticker for the invoice
  /// - [amountMsat]: The invoice amount in millisatoshis
  /// - [description]: Human-readable description for the invoice
  /// - [expiry]: Optional expiry time in seconds (default varies by implementation)
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with a [GenerateInvoiceResponse]
  /// containing the encoded invoice string and payment hash.
  ///
  /// The generated invoice includes:
  /// - Payment amount
  /// - Recipient node information
  /// - Payment description
  /// - Expiry timestamp
  Future<GenerateInvoiceResponse> generateInvoice({
    required String coin,
    required String description,
    int? amountMsat,
    int? expiry,
    String? rpcPass,
  }) {
    return execute(
      GenerateInvoiceRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        description: description,
        amountMsat: amountMsat,
        expiry: expiry,
      ),
    );
  }

  /// Pays a Lightning invoice.
  ///
  /// This method attempts to send a payment for the specified Lightning
  /// invoice. The payment is routed through the Lightning Network to
  /// reach the recipient.
  ///
  /// - [coin]: The coin ticker for the payment
  /// - [invoice]: The BOLT 11 invoice string to pay
  /// - [maxFeeMsat]: Optional maximum fee willing to pay in millisatoshis
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with a [PayInvoiceResponse]
  /// containing the payment preimage and route details.
  ///
  /// Throws an exception if:
  /// - Invoice is invalid or expired
  /// - No route to recipient is found
  /// - Insufficient channel balance
  /// - Payment fails after retries
  Future<PayInvoiceResponse> payInvoice({
    required String coin,
    required LightningPayment payment,
    String? rpcPass,
  }) {
    return execute(
      PayInvoiceRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        payment: payment,
      ),
    );
  }

  /// Retrieves Lightning payment history.
  ///
  /// This method fetches the history of Lightning payments (both sent
  /// and received) with optional filtering and pagination support.
  ///
  /// - [coin]: The coin ticker to query payment history for
  /// - [filter]: Optional filter to narrow down results
  /// - [pagination]: Optional pagination parameters
  /// - [rpcPass]: Optional RPC password override
  ///
  /// Returns a [Future] that completes with a [GetPaymentHistoryResponse]
  /// containing a list of payment records.
  ///
  /// Payment records include:
  /// - Payment hash and preimage
  /// - Amount and fees
  /// - Timestamp
  /// - Payment status
  /// - Route information
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
