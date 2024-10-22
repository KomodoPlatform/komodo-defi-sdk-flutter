// A class that provides a library of RPC methods used by the Komodo DeFi
// Framework API. This class is used to group RPC methods together and provide
// a namespace for all the methods.
// ignore_for_file: unused_field, unused_element

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods/rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoDefiRpcMethods {
  KomodoDefiRpcMethods([this._client]);

  final ApiClient? _client;

  WalletMethods get wallet => WalletMethods(_client);

  // ignore: library_private_types_in_public_api
  GeneralActivationMethods get generalActivation =>
      GeneralActivationMethods(_client);

  HdWalletMethods get hdWallet => HdWalletMethods(_client);

  TaskMethods get task => TaskMethods(_client);

  // Add other namespaces here, e.g.:
  // TradeNamespace get trade => TradeNamespace(_client);
  // UtilityNamespace get utility => UtilityNamespace(_client);
}

class TaskMethods extends BaseRpcMethodNamespace {
  TaskMethods(super.client);

  Future<TaskStatusResponse> status(int taskId, [String? rpcPass]) =>
      execute(TaskStatusRequest(taskId: taskId, rpcPass: rpcPass));
}

class WalletMethods extends BaseRpcMethodNamespace {
  WalletMethods(super.client);

  Future<GetWalletNamesResponse> getWalletNames([String? rpcPass]) =>
      execute(GetWalletNamesRequest(rpcPass));

  Future<MyBalanceResponse> myBalance({
    required String coin,
    String? rpcPass,
  }) =>
      execute(
        MyBalanceRequest(
          rpcPass: rpcPass ?? '',
          coin: coin,
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
  }) =>
      execute(
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
  }) =>
      execute(
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
  }) =>
      execute(
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
  }) =>
      execute(
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
  }) =>
      execute(
        AccountBalanceStatusRequest(
          rpcPass: rpcPass ?? this.rpcPass,
          taskId: taskId,
          forgetIfFinished: forgetIfFinished,
        ),
      );

  Future<AccountBalanceCancelResponse> accountBalanceCancel({
    required int taskId,
    String? rpcPass,
  }) =>
      execute(
        AccountBalanceCancelRequest(
          rpcPass: rpcPass ?? this.rpcPass,
          taskId: taskId,
        ),
      );
}
