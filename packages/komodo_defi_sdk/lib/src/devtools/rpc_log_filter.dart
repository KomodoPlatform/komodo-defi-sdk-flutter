/// Utility helpers for identifying RPC-related framework logs.
class RpcLogFilter {
  const RpcLogFilter._();

  /// Returns true if [message] appears to be an RPC log emitted by the SDK or
  /// underlying framework. Applications can use this to avoid double-posting
  /// RPC logs to DevTools.
  static bool isSdkRpcLog(String message) {
    return message.startsWith('[RPC]') ||
        message.startsWith('[ELECTRUM]') ||
        (message.contains('completed in') && message.contains('ms')) ||
        (message.contains('failed after') && message.contains('ms')) ||
        message.contains('RPC response:') ||
        message.contains('mm2Rpc request');
  }
}
