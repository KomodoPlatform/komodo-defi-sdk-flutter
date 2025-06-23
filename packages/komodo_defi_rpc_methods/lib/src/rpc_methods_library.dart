// TODO: Refactor RPC methods to be consistent that they accept a params
// class object where we have a request params class.

// ignore_for_file: unused_field, unused_element

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A class that provides a library of RPC methods used by the Komodo DeFi
/// Framework API. This class is used to group RPC methods together and provide
/// a namespace for all the methods.

class KomodoDefiRpcMethods {
  KomodoDefiRpcMethods([this._client]);

  final ApiClient? _client;

  // Common/general methods
  AddressMethodsNamespace get address => AddressMethodsNamespace(_client);

  WalletMethods get wallet => WalletMethods(_client);

  GeneralActivationMethods get generalActivation =>
      GeneralActivationMethods(_client);

  HdWalletMethods get hdWallet => HdWalletMethods(_client);

  TransactionHistoryMethods get transactionHistory =>
      TransactionHistoryMethods(_client);

  WithdrawMethodsNamespace get withdraw => WithdrawMethodsNamespace(_client);

  TaskMethods get task => TaskMethods(_client);

  // Protocol-specific namespaces
  Erc20MethodsNamespace get erc20 => Erc20MethodsNamespace(_client);
  UtxoMethodsNamespace get utxo => UtxoMethodsNamespace(_client);
  SlpMethodsNamespace get slp => SlpMethodsNamespace(_client);
  QtumMethodsNamespace get qtum => QtumMethodsNamespace(_client);
  TendermintMethodsNamespace get tendermint =>
      TendermintMethodsNamespace(_client);
  NftMethodsNamespace get nft => NftMethodsNamespace(_client);

  // Add other namespaces here, e.g.:
  // TradeNamespace get trade => TradeNamespace(_client);
  MessageSigningMethodsNamespace get messageSigning =>
      MessageSigningMethodsNamespace(_client);
  UtilityMethods get utility => UtilityMethods(_client);
}

class TaskMethods extends BaseRpcMethodNamespace {
  TaskMethods(super.client);

  // Future<TaskStatusResponse> status(int taskId, [String? rpcPass]) =>
  //     execute(TaskStatusRequest(taskId: taskId, rpcPass: rpcPass));
}

class WalletMethods extends BaseRpcMethodNamespace {
  WalletMethods(super.client);

  /// Changes the password used to encrypt/decrypt the mnemonic
  Future<BaseResponse> changeMnemonicPassword({
    required String currentPassword,
    required String newPassword,
    String? rpcPass,
  }) => execute(
    ChangeMnemonicPasswordRequest(
      rpcPass: rpcPass ?? '',
      currentPassword: currentPassword,
      newPassword: newPassword,
    ),
  );

  Future<GetWalletNamesResponse> getWalletNames([String? rpcPass]) =>
      execute(GetWalletNamesRequest(rpcPass));

  Future<DeleteWalletResponse> deleteWallet({
    required String walletName,
    required String password,
    String? rpcPass,
  }) => execute(
    DeleteWalletRequest(
      walletName: walletName,
      password: password,
      rpcPass: rpcPass,
    ),
  );

  Future<MyBalanceResponse> myBalance({
    required String coin,
    String? rpcPass,
  }) => execute(MyBalanceRequest(rpcPass: rpcPass ?? '', coin: coin));

  Future<GetPublicKeyHashResponse> getPublicKeyHash([String? rpcPass]) =>
      execute(GetPublicKeyHashRequest(rpcPass: rpcPass));
}

/// KDF v2 Utility Methods not specific to any larger feature
/// or namespace (e.g. current MTP, token info for custom token activation).
class UtilityMethods extends BaseRpcMethodNamespace {
  UtilityMethods(super.client);

  /// Returns the ticker and decimals values required for activation of a custom
  /// token, given a [platform], [protocolType], and [contractAddress].
  Future<GetTokenInfoResponse> getTokenInfo({
    required String protocolType,
    required String platform,
    required String contractAddress,
    String? rpcPass,
  }) => execute(
    GetTokenInfoRequest(
      protocolType: protocolType,
      platform: platform,
      contractAddress: contractAddress,
      rpcPass: rpcPass ?? '',
    ),
  );

  /// Signs a message with a coin's signing key
  Future<SignMessageResponse> signMessage({
    required String coin,
    required String message,
    String? rpcPass,
  }) => execute(
    SignMessageRequest(coin: coin, message: message, rpcPass: rpcPass ?? ''),
  );

  /// Verifies a message signature
  Future<VerifyMessageResponse> verifyMessage({
    required String coin,
    required String message,
    required String signature,
    required String address,
    String? rpcPass,
  }) => execute(
    VerifyMessageRequest(
      coin: coin,
      message: message,
      signature: signature,
      address: address,
      rpcPass: rpcPass ?? '',
    ),
  );
}

class GeneralActivationMethods extends BaseRpcMethodNamespace {
  const GeneralActivationMethods(super.client);

  Future<GetEnabledCoinsResponse> getEnabledCoins([String? rpcPass]) =>
      execute(GetEnabledCoinsRequest(rpcPass: rpcPass));
}

class HdWalletMethods extends BaseRpcMethodNamespace {
  HdWalletMethods(super.client);

  Future<GetNewAddressResponse> getNewAddress(
    String coin, {
    String? rpcPass,
    int? accountId,
    String? chain,
    int? gapLimit,
  }) => execute(
    GetNewAddressRequest(
      rpcPass: rpcPass,
      coin: coin,
      accountId: accountId,
      chain: chain,
      gapLimit: gapLimit,
    ),
  );

  Future<NewTaskResponse> scanForNewAddressesInit(
    String coin, {
    String? rpcPass,
    int? accountId,
    int? gapLimit,
  }) => execute(
    ScanForNewAddressesInitRequest(
      rpcPass: rpcPass,
      coin: coin,
      accountId: accountId,
      gapLimit: gapLimit,
    ),
  );

  Future<ScanForNewAddressesStatusResponse> scanForNewAddressesStatus(
    int taskId, {
    String? rpcPass,
    bool forgetIfFinished = true,
  }) => execute(
    ScanForNewAddressesStatusRequest(
      rpcPass: rpcPass,
      taskId: taskId,
      forgetIfFinished: forgetIfFinished,
    ),
  );

  Future<NewTaskResponse> accountBalanceInit({
    required String coin,
    required int accountIndex,
    String? rpcPass,
  }) => execute(
    AccountBalanceInitRequest(
      rpcPass: rpcPass ?? this.rpcPass,
      coin: coin,
      accountIndex: accountIndex,
    ),
  );

  Future<AccountBalanceStatusResponse> accountBalanceStatus({
    required int taskId,
    bool forgetIfFinished = true,
    String? rpcPass,
  }) => execute(
    AccountBalanceStatusRequest(
      rpcPass: rpcPass ?? this.rpcPass,
      taskId: taskId,
      forgetIfFinished: forgetIfFinished,
    ),
  );

  Future<AccountBalanceCancelResponse> accountBalanceCancel({
    required int taskId,
    String? rpcPass,
  }) => execute(
    AccountBalanceCancelRequest(
      rpcPass: rpcPass ?? this.rpcPass,
      taskId: taskId,
    ),
  );
}
