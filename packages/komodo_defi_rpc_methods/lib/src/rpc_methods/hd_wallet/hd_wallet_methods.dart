// TODO: Refactor RPC methods to be consistent that they accept a params
// class object where we have a request params class.

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

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
      rpcPass: rpcPass ?? this.rpcPass,
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
      rpcPass: rpcPass ?? this.rpcPass,
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
      rpcPass: rpcPass ?? this.rpcPass,
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

  // Task-based get_new_address methods
  Future<NewTaskResponse> getNewAddressTaskInit({
    required String coin,
    int? accountId,
    String? chain,
    int? gapLimit,
    String? rpcPass,
  }) => execute(
    GetNewAddressTaskInitRequest(
      rpcPass: rpcPass ?? this.rpcPass,
      coin: coin,
      accountId: accountId,
      chain: chain,
      gapLimit: gapLimit,
    ),
  );

  Future<GetNewAddressTaskStatusResponse> getNewAddressTaskStatus({
    required int taskId,
    bool forgetIfFinished = true,
    String? rpcPass,
  }) => execute(
    GetNewAddressTaskStatusRequest(
      rpcPass: rpcPass ?? this.rpcPass,
      taskId: taskId,
      forgetIfFinished: forgetIfFinished,
    ),
  );

  Future<GetNewAddressTaskCancelResponse> getNewAddressTaskCancel({
    required int taskId,
    String? rpcPass,
  }) => execute(
    GetNewAddressTaskCancelRequest(
      rpcPass: rpcPass ?? this.rpcPass,
      taskId: taskId,
    ),
  );
}
