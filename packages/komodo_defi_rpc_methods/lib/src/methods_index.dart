// A class that provides a library of RPC methods used by the Komodo DeFi
// Framework API. This class is used to group RPC methods together and provide
// a namespace for all the methods.
// ignore_for_file: unused_field, unused_element

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class RpcMethods {
  // ignore: public_member_api_docs, library_private_types_in_public_api
  static const _GuiStorageMethods guiStorage = _GuiStorageMethods();
}

class _GuiStorageMethods {
  const _GuiStorageMethods();

  AddAccountRequest addAccount({required NewAccount account}) =>
      AddAccountRequest(account: account);

  static SetAccountNameRequest setAccountName({
    required AccountId accountId,
    required String name,
  }) =>
      SetAccountNameRequest(accountId: accountId, name: name);
}
