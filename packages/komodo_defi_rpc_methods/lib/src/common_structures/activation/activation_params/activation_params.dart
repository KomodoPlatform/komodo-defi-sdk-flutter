import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class ActivationParams {
  ActivationParams({
    this.requiredConfirmations,
    this.requiresNotarization = false,
    this.privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
    this.minAddressesNumber,
    this.scanPolicy,
    this.gapLimit,
    this.mode,
  });
  final int? requiredConfirmations;
  final bool requiresNotarization;
  final PrivateKeyPolicy privKeyPolicy;
  final int? minAddressesNumber;
  final String? scanPolicy;
  final int? gapLimit;

  final ActivationMode? mode;

  Map<String, dynamic> toJson();
}

enum PrivateKeyPolicy {
  contextPrivKey,
  trezor;

  String get id {
    switch (this) {
      case PrivateKeyPolicy.contextPrivKey:
        return 'ContextPrivKey';
      case PrivateKeyPolicy.trezor:
        return 'Trezor';
    }
  }
}

class ActivationMode {
  ActivationMode({
    required this.rpc,
    this.rpcData,
  });
  final String rpc;
  final ActivationRpcData? rpcData;

  Map<String, dynamic> toJsonRequest() => {
        'rpc': rpc,
        if (rpcData != null) 'rpc_data': rpcData!.toJsonRequest(),
      };
}

class ActivationRpcData {
  ActivationRpcData({
    this.lightWalletDServers,
    this.electrumServers,
    this.electrum,
    this.syncParams,
  });
  final List<String>? lightWalletDServers;
  final List<ActivationServers>? electrumServers;
  final List<ActivationServers>? electrum;
  final dynamic syncParams;

  // Map<String, dynamic> toJson() => {
  //       if (lightWalletDServers != null)
  //         'light_wallet_d_servers': lightWalletDServers,
  //       if (electrumServers != null)
  //         'electrum_servers': electrumServers!.map((e) => e.toJson()).toList(),
  //       if (electrum != null)
  //         'electrum': electrum!.map((e) => e.toJson()).toList(),
  //       if (syncParams != null) 'sync_params': syncParams,
  //     };

  Map<String, dynamic> toJsonRequest() => {
        if (lightWalletDServers != null)
          'light_wallet_d_servers': lightWalletDServers,
        if (electrumServers != null)
          'servers': electrumServers!.map((e) => e.toJsonRequest()).toList(),
        if (electrum != null)
          'servers': electrum!.map((e) => e.toJsonRequest()).toList(),
        if (syncParams != null) 'sync_params': syncParams,
      };
}

class ActivationServers {
  ActivationServers({
    required this.url,
    this.wsUrl,
    this.protocol = 'TCP',
    this.disableCertVerification = false,
  });

  factory ActivationServers.fromJsonConfig(Map<String, dynamic> config) {
    return ActivationServers(
      url: config.value<String>('url'),
      wsUrl: config.valueOrNull<String>('ws_url'),
      protocol: config.valueOrNull<String>('protocol') ?? 'TCP',
      disableCertVerification:
          config.valueOrNull<bool>('disable_cert_verification') ?? false,
    );
  }

  final String url;
  final String? wsUrl;
  final String protocol;
  final bool disableCertVerification;

  Map<String, dynamic> toJsonRequest() => {
        'url': url,
        if (wsUrl != null) 'ws_url': wsUrl,
        'protocol': protocol,
        'disable_cert_verification': disableCertVerification,
      };
}
