/// Runtime options for coin config parsing and filtering.
///
/// These options allow the embedding application to tweak how the coins
/// configuration is filtered at runtime without changing the source
/// `coins_config` variant mapping.
class CoinConfigRuntimeOptions {
  const CoinConfigRuntimeOptions._();

  /// When true on native platforms, keep the full non-WSS Electrum list
  /// (both TCP and SSL). When false (default), filter to SSL-only on native.
  ///
  /// This flag has no effect on web where only WSS servers are used.
  static bool useFullElectrumServersOnNative = false;
}


