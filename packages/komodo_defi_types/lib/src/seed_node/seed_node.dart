import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Represents a seed node configuration with contact information.
class SeedNode {
  const SeedNode({
    required this.name,
    required this.host,
    required this.type,
    required this.wss,
    required this.netId,
    required this.contact,
  });

  /// Creates a [SeedNode] from a JSON map.
  factory SeedNode.fromJson(JsonMap json) {
    return SeedNode(
      name: json.value<String>('name'),
      host: json.value<String>('host'),
      type: json.value<String>('type'),
      wss: json.value<bool>('wss'),
      netId: json.value<int>('netid'),
      contact: json
          .value<List<dynamic>>('contact')
          .cast<JsonMap>()
          .map(SeedNodeContact.fromJson)
          .toList(),
    );
  }

  /// The name identifier for the seed node
  final String name;

  /// The host address (domain or IP) for the seed node
  final String host;

  /// Contact information for the seed node
  final List<SeedNodeContact> contact;

  /// The connection type of the seed node (e.g. domain or ip)
  final String type;

  /// Whether the seed node supports secure websockets
  final bool wss;

  /// The network identifier for the seed node
  final int netId;

  /// Converts this [SeedNode] to a JSON map.
  JsonMap toJson() {
    return {
      'name': name,
      'host': host,
      'type': type,
      'wss': wss,
      'netid': netId,
      'contact': contact.map((c) => c.toJson()).toList(),
    };
  }

  /// Creates a list of [SeedNode]s from a JSON list.
  static List<SeedNode> fromJsonList(JsonList jsonList) {
    return jsonList.map(SeedNode.fromJson).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeedNode &&
        other.name == name &&
        other.host == host &&
        other.type == type &&
        other.wss == wss &&
        other.netId == netId &&
        _listEquals(other.contact, contact);
  }

  @override
  int get hashCode => Object.hash(name, host, type, wss, netId, Object.hashAll(contact));

  @override
  String toString() =>
      'SeedNode(name: $name, host: $host, type: $type, wss: $wss, netId: $netId, contact: $contact)';

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Represents contact information for a seed node.
class SeedNodeContact {
  const SeedNodeContact({
    required this.email,
  });

  /// Creates a [SeedNodeContact] from a JSON map.
  factory SeedNodeContact.fromJson(JsonMap json) {
    return SeedNodeContact(
      email: json.value<String>('email'),
    );
  }

  /// The email contact for the seed node
  final String email;

  /// Converts this [SeedNodeContact] to a JSON map.
  JsonMap toJson() {
    return {
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeedNodeContact && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() => 'SeedNodeContact(email: $email)';
}
