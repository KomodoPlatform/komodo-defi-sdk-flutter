import 'package:komodo_defi_rpc_methods/src/common_structures/orderbook/order_address.dart';
import 'package:komodo_defi_rpc_methods/src/common_structures/primitive/numeric_value.dart';
import 'package:komodo_defi_rpc_methods/src/common_structures/trading/order_status.dart'
    show OrderConfirmationSettings;
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Represents information about an order in the orderbook.
///
/// This class contains all the essential details about a trading order,
/// including pricing, volume constraints, and metadata about the order creator.
/// It's used to represent both bid and ask orders in orderbook responses.
class OrderInfo {
  /// Creates a new [OrderInfo] instance.
  ///
  /// All parameters are optional to allow partial payloads from the API.
  const OrderInfo({
    this.uuid,
    this.address,
    this.baseMaxVolume,
    this.baseMaxVolumeAggregated,
    this.baseMinVolume,
    this.coin,
    this.confSettings,
    this.isMine,
    this.price,
    this.pubkey,
    this.relMaxVolume,
    this.relMaxVolumeAggregated,
    this.relMinVolume,
  });

  /// Creates an [OrderInfo] instance from a JSON map.
  ///
  /// Parses only the v2 orderbook schema fields without legacy fallbacks.
  factory OrderInfo.fromJson(JsonMap json) {
    final priceJson = json.valueOrNull<JsonMap>('price');
    final baseMaxVolumeJson = json.valueOrNull<JsonMap>('base_max_volume');
    final baseMaxVolumeAggrJson = json.valueOrNull<JsonMap>(
      'base_max_volume_aggr',
    );
    final baseMinVolumeJson = json.valueOrNull<JsonMap>('base_min_volume');
    final relMaxVolumeJson = json.valueOrNull<JsonMap>('rel_max_volume');
    final relMaxVolumeAggrJson = json.valueOrNull<JsonMap>(
      'rel_max_volume_aggr',
    );
    final relMinVolumeJson = json.valueOrNull<JsonMap>('rel_min_volume');
    final addressJson = json.valueOrNull<JsonMap>('address');
    final confSettingsJson = json.valueOrNull<JsonMap>('conf_settings');

    return OrderInfo(
      uuid: json.valueOrNull<String>('uuid'),
      coin: json.valueOrNull<String>('coin'),
      pubkey: json.valueOrNull<String>('pubkey'),
      isMine: json.valueOrNull<bool>('is_mine'),
      price: priceJson != null ? NumericValue.fromJson(priceJson) : null,
      baseMaxVolume: baseMaxVolumeJson != null
          ? NumericValue.fromJson(baseMaxVolumeJson)
          : null,
      baseMaxVolumeAggregated: baseMaxVolumeAggrJson != null
          ? NumericValue.fromJson(baseMaxVolumeAggrJson)
          : null,
      baseMinVolume: baseMinVolumeJson != null
          ? NumericValue.fromJson(baseMinVolumeJson)
          : null,
      relMaxVolume: relMaxVolumeJson != null
          ? NumericValue.fromJson(relMaxVolumeJson)
          : null,
      relMaxVolumeAggregated: relMaxVolumeAggrJson != null
          ? NumericValue.fromJson(relMaxVolumeAggrJson)
          : null,
      relMinVolume: relMinVolumeJson != null
          ? NumericValue.fromJson(relMinVolumeJson)
          : null,
      address: addressJson != null ? OrderAddress.fromJson(addressJson) : null,
      confSettings: confSettingsJson != null
          ? OrderConfirmationSettings.fromJson(confSettingsJson)
          : null,
    );
  }

  /// Unique identifier for this order, if provided.
  final String? uuid;

  /// Optional structured address information for the order maker.
  final OrderAddress? address;

  /// Optional maximum base volume.
  final NumericValue? baseMaxVolume;

  /// Optional aggregated maximum base volume across orderbook depth.
  final NumericValue? baseMaxVolumeAggregated;

  /// Optional minimum base volume.
  final NumericValue? baseMinVolume;

  /// Optional coin ticker.
  final String? coin;

  /// Optional confirmation settings supplied by the API.
  final OrderConfirmationSettings? confSettings;

  /// Indicates whether the order belongs to the current wallet.
  final bool? isMine;

  /// Optional price for the order.
  final NumericValue? price;

  /// Optional public key of the order creator.
  final String? pubkey;

  /// Optional maximum rel volume.
  final NumericValue? relMaxVolume;

  /// Optional aggregated maximum rel volume across orderbook depth.
  final NumericValue? relMaxVolumeAggregated;

  /// Optional minimum rel volume.
  final NumericValue? relMinVolume;

  /// Converts this [OrderInfo] instance to a JSON map.
  ///
  /// The resulting map can be serialized to JSON and will contain all
  /// the order information in the expected API format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': ?uuid,
      'coin': ?coin,
      'pubkey': ?pubkey,
      'is_mine': ?isMine,
      'price': ?price?.toJson(),
      'base_max_volume': ?baseMaxVolume?.toJson(),
      'base_max_volume_aggr': ?baseMaxVolumeAggregated?.toJson(),
      'base_min_volume': ?baseMinVolume?.toJson(),
      'rel_max_volume': ?relMaxVolume?.toJson(),
      'rel_max_volume_aggr': ?relMaxVolumeAggregated?.toJson(),
      'rel_min_volume': ?relMinVolume?.toJson(),
      'address': ?address?.toJson(),
      'conf_settings': ?confSettings?.toJson(),
    };
  }
}
