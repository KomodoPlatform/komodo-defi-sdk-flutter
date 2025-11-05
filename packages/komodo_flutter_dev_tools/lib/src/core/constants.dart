class DevToolsEventKinds {
  const DevToolsEventKinds._();

  static const logEntry = 'ext.komodo.log.entry';
  static const logBatch = 'ext.komodo.log.batch';
  static const rpcCall = 'ext.komodo.rpc.call';
  static const rpcBatch = 'ext.komodo.rpc.batch';
  static const rpcSummary = 'ext.komodo.rpc.summary';
  static const rpcInsight = 'ext.komodo.rpc.insight';
}

class DevToolsServiceExtensions {
  const DevToolsServiceExtensions._();

  static const fetchLogSnapshot = 'ext.komodo.logs.snapshot';
  static const fetchRpcSnapshot = 'ext.komodo.rpc.snapshot';
  static const toggleRpcTracing = 'ext.komodo.rpc.toggleTracing';
  static const requestInsightRefresh = 'ext.komodo.rpc.refreshInsights';
}

class KomodoDevToolsConstants {
  const KomodoDevToolsConstants._();

  static const extensionDisplayName = 'Komodo Dev Tools';
  static const extensionPackageName = 'komodo_flutter_dev_tools';

  static const maxRetainedLogs = 2500;
  static const maxRetainedRpcCalls = 1500;
  static const logSnapshotRequestTimeout = Duration(seconds: 6);
  static const analyticsWindow = Duration(minutes: 10);
}
