import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:rational/rational.dart';
import '../primitive/mm2_rational.dart';
import '../primitive/fraction.dart';

/// Represents information about an order in the orderbook.
/// 
/// This class contains all the essential details about a trading order,
/// including pricing, volume constraints, and metadata about the order creator.
/// It's used to represent both bid and ask orders in orderbook responses.
class OrderInfo {
  /// Creates a new [OrderInfo] instance.
  /// 
  /// All parameters are required and represent core order attributes:
  /// - [uuid]: Unique identifier for the order
  /// - [price]: The price per unit in rel coin
  /// - [maxVolume]: Maximum volume available for this order
  /// - [minVolume]: Minimum volume that must be traded
  /// - [pubkey]: Public key of the order creator
  /// - [age]: Age of the order in seconds
  /// - [zcredits]: Zero-knowledge credits associated with the order
  /// - [coin]: The coin being offered in this order
  /// - [address]: The address associated with this order
  OrderInfo({
    required this.uuid,
    required this.price,
    required this.maxVolume,
    required this.minVolume,
    required this.pubkey,
    required this.age,
    required this.zcredits,
    required this.coin,
    required this.address,
    this.priceFraction,
    this.priceRat,
    this.maxVolumeFraction,
    this.maxVolumeRat,
    this.minVolumeFraction,
    this.minVolumeRat,
  });

  /// Creates an [OrderInfo] instance from a JSON map.
  /// 
  /// Expects the following keys in the JSON:
  /// - `uuid`: String - Unique order identifier
  /// - `price`: String - Price per unit
  /// - `max_volume`: String - Maximum tradeable volume
  /// - `min_volume`: String - Minimum tradeable volume
  /// - `pubkey`: String - Order creator's public key
  /// - `age`: int - Order age in seconds
  /// - `zcredits`: int - Zero-knowledge credits
  /// - `coin`: String - Coin ticker
  /// - `address`: String - Associated address
  factory OrderInfo.fromJson(JsonMap json) {
    return OrderInfo(
      uuid: json.value<String>('uuid'),
      price: json.value<String>('price'),
      maxVolume: json.value<String>('max_volume'),
      minVolume: json.value<String>('min_volume'),
      pubkey: json.value<String>('pubkey'),
      age: json.value<int>('age'),
      zcredits: json.value<int>('zcredits'),
      coin: json.value<String>('coin'),
      address: json.value<String>('address'),
      priceFraction:
          json.valueOrNull<JsonMap>('price_fraction') != null
              ? Fraction.fromJson(json.value<JsonMap>('price_fraction'))
              : null,
      priceRat:
          json.valueOrNull<List<dynamic>>('price_rat') != null
              ? rationalFromMm2(json.value<List<dynamic>>('price_rat'))
              : null,
      maxVolumeFraction:
          json.valueOrNull<JsonMap>('max_volume_fraction') != null
              ? Fraction.fromJson(json.value<JsonMap>('max_volume_fraction'))
              : null,
      maxVolumeRat:
          json.valueOrNull<List<dynamic>>('max_volume_rat') != null
              ? rationalFromMm2(json.value<List<dynamic>>('max_volume_rat'))
              : null,
      minVolumeFraction:
          json.valueOrNull<JsonMap>('min_volume_fraction') != null
              ? Fraction.fromJson(json.value<JsonMap>('min_volume_fraction'))
              : null,
      minVolumeRat:
          json.valueOrNull<List<dynamic>>('min_volume_rat') != null
              ? rationalFromMm2(json.value<List<dynamic>>('min_volume_rat'))
              : null,
    );
  }

  /// Unique identifier for this order.
  /// 
  /// This UUID is used to reference the order in subsequent operations
  /// such as order matching or cancellation.
  final String uuid;

  /// The price per unit for this order.
  /// 
  /// Expressed as a string to maintain precision. This represents the
  /// exchange rate between the base and rel coins.
  final String price;

  /// Maximum volume available for trading in this order.
  /// 
  /// This is the total amount of the coin that can be traded through
  /// this order. Expressed as a string to maintain precision.
  final String maxVolume;

  /// Minimum volume that must be traded.
  /// 
  /// Orders cannot be partially filled below this threshold. This helps
  /// prevent dust trades and ensures economically viable transactions.
  /// Expressed as a string to maintain precision.
  final String minVolume;

  /// Public key of the order creator.
  /// 
  /// This identifies the node that created the order and is used for
  /// P2P communication during swap negotiation.
  final String pubkey;

  /// Age of the order in seconds.
  /// 
  /// Indicates how long ago this order was created. Useful for sorting
  /// orders by recency or implementing time-based order preferences.
  final int age;

  /// Zero-knowledge credits associated with this order.
  /// 
  /// Used in privacy-enhanced trading to manage reputation and trading
  /// privileges without revealing identity.
  final int zcredits;

  /// The coin ticker for this order.
  /// 
  /// Identifies which coin is being offered in this order.
  final String coin;

  /// The address associated with this order.
  /// 
  /// This is typically the address that will receive funds in a swap
  /// involving this order.
  final String address;

  /// Optional fractional representation of the price
  final Fraction? priceFraction;

  /// Optional rational representation of the price
  final Rational? priceRat;

  /// Optional fractional representation of the maximum volume
  final Fraction? maxVolumeFraction;

  /// Optional rational representation of the maximum volume
  final Rational? maxVolumeRat;

  /// Optional fractional representation of the minimum volume
  final Fraction? minVolumeFraction;

  /// Optional rational representation of the minimum volume
  final Rational? minVolumeRat;

  /// Converts this [OrderInfo] instance to a JSON map.
  /// 
  /// The resulting map can be serialized to JSON and will contain all
  /// the order information in the expected API format.
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'price': price,
    'max_volume': maxVolume,
    'min_volume': minVolume,
    'pubkey': pubkey,
    'age': age,
    'zcredits': zcredits,
    'coin': coin,
    'address': address,
    if (priceFraction != null) 'price_fraction': priceFraction!.toJson(),
    if (priceRat != null) 'price_rat': rationalToMm2(priceRat!),
    if (maxVolumeFraction != null)
      'max_volume_fraction': maxVolumeFraction!.toJson(),
    if (maxVolumeRat != null) 'max_volume_rat': rationalToMm2(maxVolumeRat!),
    if (minVolumeFraction != null)
      'min_volume_fraction': minVolumeFraction!.toJson(),
    if (minVolumeRat != null) 'min_volume_rat': rationalToMm2(minVolumeRat!),
  };
}