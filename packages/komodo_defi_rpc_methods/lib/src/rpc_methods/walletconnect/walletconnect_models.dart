import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

// Request classes for WalletConnect operations

/// Request to create a new WalletConnect connection
class WcNewConnectionRequest
    extends BaseRequest<WcNewConnectionResponse, GeneralErrorResponse> {
  WcNewConnectionRequest({required this.requiredNamespaces, super.rpcPass})
    : super(method: 'wc_new_connection', mmrpc: RpcVersion.v2_0);

  final WcRequiredNamespaces requiredNamespaces;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'required_namespaces': requiredNamespaces.toJson()},
  };

  @override
  WcNewConnectionResponse parse(Map<String, dynamic> json) {
    return WcNewConnectionResponse.parse(json);
  }
}

/// Request to get all active WalletConnect sessions
class WcGetSessionsRequest
    extends BaseRequest<WcGetSessionsResponse, GeneralErrorResponse> {
  WcGetSessionsRequest({super.rpcPass})
    : super(method: 'wc_get_sessions', mmrpc: RpcVersion.v2_0);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    ...super.toJson(),
    'params': <String, dynamic>{},
  };

  @override
  WcGetSessionsResponse parse(Map<String, dynamic> json) {
    return WcGetSessionsResponse.parse(json);
  }
}

/// Request to get a specific WalletConnect session
class WcGetSessionRequest
    extends BaseRequest<WcGetSessionResponse, GeneralErrorResponse> {
  WcGetSessionRequest({
    required this.topic,
    this.withPairingTopic = false,
    super.rpcPass,
  }) : super(method: 'wc_get_session', mmrpc: RpcVersion.v2_0);

  final String topic;
  final bool withPairingTopic;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'topic': topic, 'with_pairing_topic': withPairingTopic},
  };

  @override
  WcGetSessionResponse parse(Map<String, dynamic> json) {
    return WcGetSessionResponse.parse(json);
  }
}

/// Request to ping a WalletConnect session
class WcPingSessionRequest
    extends BaseRequest<WcPingSessionResponse, GeneralErrorResponse> {
  WcPingSessionRequest({required this.topic, super.rpcPass})
    : super(method: 'wc_ping_session', mmrpc: RpcVersion.v2_0);

  final String topic;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'topic': topic},
  };

  @override
  WcPingSessionResponse parse(Map<String, dynamic> json) {
    return WcPingSessionResponse.parse(json);
  }
}

/// Request to delete a WalletConnect session
class WcDeleteSessionRequest
    extends BaseRequest<WcDeleteSessionResponse, GeneralErrorResponse> {
  WcDeleteSessionRequest({required this.topic, super.rpcPass})
    : super(method: 'wc_delete_session', mmrpc: RpcVersion.v2_0);

  final String topic;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'topic': topic},
  };

  @override
  WcDeleteSessionResponse parse(Map<String, dynamic> json) {
    return WcDeleteSessionResponse.parse(json);
  }
}

// Response classes for WalletConnect operations

/// Response from creating a new WalletConnect connection
class WcNewConnectionResponse extends BaseResponse {
  WcNewConnectionResponse({required super.mmrpc, required this.uri});

  factory WcNewConnectionResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return WcNewConnectionResponse(
      mmrpc: json.value<String>('mmrpc'),
      uri: result.value<String>('uri'),
    );
  }

  final String uri;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'uri': uri},
    };
  }
}

/// Response from getting all WalletConnect sessions
class WcGetSessionsResponse extends BaseResponse {
  WcGetSessionsResponse({required super.mmrpc, required this.sessions});

  factory WcGetSessionsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    final sessionsList = result.value<List<dynamic>>('sessions');

    return WcGetSessionsResponse(
      mmrpc: json.value<String>('mmrpc'),
      sessions: sessionsList
          .map((session) => WcSession.fromJson(session as JsonMap))
          .toList(),
    );
  }

  final List<WcSession> sessions;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {
        'sessions': sessions.map((session) => session.toJson()).toList(),
      },
    };
  }
}

/// Response from getting a specific WalletConnect session
class WcGetSessionResponse extends BaseResponse {
  WcGetSessionResponse({required super.mmrpc, required this.session});

  factory WcGetSessionResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return WcGetSessionResponse(
      mmrpc: json.value<String>('mmrpc'),
      session: WcSession.fromJson(result.value<JsonMap>('session')),
    );
  }

  final WcSession session;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'session': session.toJson()},
    };
  }
}

/// Response from pinging a WalletConnect session
class WcPingSessionResponse extends BaseResponse {
  WcPingSessionResponse({
    required super.mmrpc,
    required this.status,
    this.message,
  });

  factory WcPingSessionResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return WcPingSessionResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: result.value<String>('status'),
      message: result.valueOrNull<String>('message'),
    );
  }

  final String status;
  final String? message;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'status': status, if (message != null) 'message': message},
    };
  }
}

/// Response from deleting a WalletConnect session
class WcDeleteSessionResponse extends BaseResponse {
  WcDeleteSessionResponse({required super.mmrpc, required this.result});

  factory WcDeleteSessionResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return WcDeleteSessionResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: result.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'result': result},
    };
  }
}

// Data model classes for WalletConnect

/// Required namespaces for WalletConnect connection
class WcRequiredNamespaces {
  WcRequiredNamespaces({this.eip155, this.cosmos});

  factory WcRequiredNamespaces.fromJson(JsonMap json) {
    return WcRequiredNamespaces(
      eip155: json.valueOrNull<JsonMap>('eip155') != null
          ? WcConnNs.fromJson(json.value<JsonMap>('eip155'))
          : null,
      cosmos: json.valueOrNull<JsonMap>('cosmos') != null
          ? WcConnNs.fromJson(json.value<JsonMap>('cosmos'))
          : null,
    );
  }

  final WcConnNs? eip155;
  final WcConnNs? cosmos;

  JsonMap toJson() {
    return {
      if (eip155 != null) 'eip155': eip155!.toJson(),
      if (cosmos != null) 'cosmos': cosmos!.toJson(),
    };
  }
}

/// Connection namespace specification
class WcConnNs {
  WcConnNs({required this.chains, required this.methods, required this.events});

  factory WcConnNs.fromJson(JsonMap json) {
    return WcConnNs(
      chains: json
          .value<List<dynamic>>('chains')
          .map((chain) => chain as String)
          .toList(),
      methods: json
          .value<List<dynamic>>('methods')
          .map((method) => method as String)
          .toList(),
      events: json
          .value<List<dynamic>>('events')
          .map((event) => event as String)
          .toList(),
    );
  }

  final List<String> chains;
  final List<String> methods;
  final List<String> events;

  JsonMap toJson() {
    return {'chains': chains, 'methods': methods, 'events': events};
  }
}

/// WalletConnect session information
class WcSession {
  WcSession({
    required this.topic,
    required this.metadata,
    required this.pairingTopic,
    required this.namespaces,
    required this.expiry,
  });

  factory WcSession.fromJson(JsonMap json) {
    final namespacesMap = json.value<JsonMap>('namespaces');
    final namespaces = <String, WcNamespace>{};

    for (final entry in namespacesMap.entries) {
      namespaces[entry.key] = WcNamespace.fromJson(entry.value as JsonMap);
    }

    return WcSession(
      topic: json.value<String>('topic'),
      metadata: WcMetadata.fromJson(json.value<JsonMap>('metadata')),
      pairingTopic: json.value<String>('pairing_topic'),
      namespaces: namespaces,
      expiry: json.value<int>('expiry'),
    );
  }

  final String topic;
  final WcMetadata metadata;
  final String pairingTopic;
  final Map<String, WcNamespace> namespaces;
  final int expiry;

  JsonMap toJson() {
    final namespacesJson = <String, dynamic>{};
    for (final entry in namespaces.entries) {
      namespacesJson[entry.key] = entry.value.toJson();
    }

    return {
      'topic': topic,
      'metadata': metadata.toJson(),
      'pairing_topic': pairingTopic,
      'namespaces': namespacesJson,
      'expiry': expiry,
    };
  }
}

/// WalletConnect metadata information
class WcMetadata {
  WcMetadata({
    required this.name,
    required this.description,
    required this.url,
    required this.icons,
  });

  factory WcMetadata.fromJson(JsonMap json) {
    return WcMetadata(
      name: json.value<String>('name'),
      description: json.value<String>('description'),
      url: json.value<String>('url'),
      icons: json
          .value<List<dynamic>>('icons')
          .map((icon) => icon as String)
          .toList(),
    );
  }

  final String name;
  final String description;
  final String url;
  final List<String> icons;

  JsonMap toJson() {
    return {
      'name': name,
      'description': description,
      'url': url,
      'icons': icons,
    };
  }
}

/// WalletConnect namespace information for sessions
class WcNamespace {
  WcNamespace({
    required this.chains,
    required this.methods,
    required this.events,
    required this.accounts,
  });

  factory WcNamespace.fromJson(JsonMap json) {
    return WcNamespace(
      chains: json
          .value<List<dynamic>>('chains')
          .map((chain) => chain as String)
          .toList(),
      methods: json
          .value<List<dynamic>>('methods')
          .map((method) => method as String)
          .toList(),
      events: json
          .value<List<dynamic>>('events')
          .map((event) => event as String)
          .toList(),
      accounts: json
          .value<List<dynamic>>('accounts')
          .map((account) => account as String)
          .toList(),
    );
  }

  final List<String> chains;
  final List<String> methods;
  final List<String> events;
  final List<String> accounts;

  JsonMap toJson() {
    return {
      'chains': chains,
      'methods': methods,
      'events': events,
      'accounts': accounts,
    };
  }
}
