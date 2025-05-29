import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Represents order data as returned by trading methods
class OrderData {
  OrderData({
    required this.coin,
    required this.address,
    required this.price,
    required this.pubkey,
    required this.uuid,
    required this.isMine,
    required this.baseMaxVolume,
    required this.baseMinVolume,
    required this.relMaxVolume,
    required this.relMinVolume,
    this.confSettings,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      coin: json.value<String>('coin'),
      address: AddressData.fromJson(json.value<JsonMap>('address')),
      price: PriceData.fromJson(json.value<JsonMap>('price')),
      pubkey: json.value<String>('pubkey'),
      uuid: json.value<String>('uuid'),
      isMine: json.value<bool>('is_mine'),
      baseMaxVolume: VolumeData.fromJson(
        json.value<JsonMap>('base_max_volume'),
      ),
      baseMinVolume: VolumeData.fromJson(
        json.value<JsonMap>('base_min_volume'),
      ),
      relMaxVolume: VolumeData.fromJson(json.value<JsonMap>('rel_max_volume')),
      relMinVolume: VolumeData.fromJson(json.value<JsonMap>('rel_min_volume')),
      confSettings:
          json.valueOrNull<JsonMap>('conf_settings') != null
              ? OrderConfigurationSettings.fromJson(
                json.value<JsonMap>('conf_settings'),
              )
              : null,
    );
  }

  /// The ticker of the coin
  final String coin;

  /// Address information for the order
  final AddressData address;

  /// Price information for the order
  final PriceData price;

  /// Public key of the order creator
  final String pubkey;

  /// Unique identifier for the order
  final String uuid;

  /// Whether this order belongs to the current user
  final bool isMine;

  /// Maximum base volume
  final VolumeData baseMaxVolume;

  /// Minimum base volume
  final VolumeData baseMinVolume;

  /// Maximum relative volume
  final VolumeData relMaxVolume;

  /// Minimum relative volume
  final VolumeData relMinVolume;

  /// Configuration settings for the order
  final OrderConfigurationSettings? confSettings;

  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'address': address.toJson(),
      'price': price.toJson(),
      'pubkey': pubkey,
      'uuid': uuid,
      'is_mine': isMine,
      'base_max_volume': baseMaxVolume.toJson(),
      'base_min_volume': baseMinVolume.toJson(),
      'rel_max_volume': relMaxVolume.toJson(),
      'rel_min_volume': relMinVolume.toJson(),
      if (confSettings != null) 'conf_settings': confSettings!.toJson(),
    };
  }
}

/// Address data for an order
class AddressData {
  AddressData({required this.addressData});

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(addressData: json.value<String>('address_data'));
  }

  /// The address string
  final String addressData;

  Map<String, dynamic> toJson() {
    return {'address_data': addressData};
  }
}

/// Price data for an order
class PriceData {
  PriceData({this.decimal, this.rational, this.fraction});

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      decimal: json.valueOrNull<String>('decimal'),
      rational: json.valueOrNull<List>('rational'),
      fraction:
          json.valueOrNull<JsonMap>('fraction') != null
              ? FractionData.fromJson(json.value<JsonMap>('fraction'))
              : null,
    );
  }

  /// Price in decimal format
  final String? decimal;

  /// Price in rational format
  final List<dynamic>? rational;

  /// Price in fraction format
  final FractionData? fraction;

  Map<String, dynamic> toJson() {
    return {
      if (decimal != null) 'decimal': decimal,
      if (rational != null) 'rational': rational,
      if (fraction != null) 'fraction': fraction!.toJson(),
    };
  }
}

/// Volume data for an order
class VolumeData {
  VolumeData({this.decimal, this.rational, this.fraction});

  factory VolumeData.fromJson(Map<String, dynamic> json) {
    return VolumeData(
      decimal: json.valueOrNull<String>('decimal'),
      rational: json.valueOrNull<List>('rational'),
      fraction:
          json.valueOrNull<JsonMap>('fraction') != null
              ? FractionData.fromJson(json.value<JsonMap>('fraction'))
              : null,
    );
  }

  /// Volume in decimal format
  final String? decimal;

  /// Volume in rational format
  final List<dynamic>? rational;

  /// Volume in fraction format
  final FractionData? fraction;

  Map<String, dynamic> toJson() {
    return {
      if (decimal != null) 'decimal': decimal,
      if (rational != null) 'rational': rational,
      if (fraction != null) 'fraction': fraction!.toJson(),
    };
  }
}

/// Fraction data representation
class FractionData {
  FractionData({required this.numer, required this.denom});

  factory FractionData.fromJson(Map<String, dynamic> json) {
    return FractionData(
      numer: json.value<String>('numer'),
      denom: json.value<String>('denom'),
    );
  }

  /// Numerator
  final String numer;

  /// Denominator
  final String denom;

  Map<String, dynamic> toJson() {
    return {'numer': numer, 'denom': denom};
  }
}

/// Configuration settings for an order
class OrderConfigurationSettings {
  OrderConfigurationSettings({
    this.baseConfirm,
    this.baseNota,
    this.relConfirm,
    this.relNota,
  });

  factory OrderConfigurationSettings.fromJson(Map<String, dynamic> json) {
    return OrderConfigurationSettings(
      baseConfirm: json.valueOrNull<int>('base_confs'),
      baseNota: json.valueOrNull<bool>('base_nota'),
      relConfirm: json.valueOrNull<int>('rel_confs'),
      relNota: json.valueOrNull<bool>('rel_nota'),
    );
  }

  /// Base confirmations required
  final int? baseConfirm;

  /// Base nota setting
  final bool? baseNota;

  /// Relative confirmations required
  final int? relConfirm;

  /// Relative nota setting
  final bool? relNota;

  Map<String, dynamic> toJson() {
    return {
      if (baseConfirm != null) 'base_confs': baseConfirm,
      if (baseNota != null) 'base_nota': baseNota,
      if (relConfirm != null) 'rel_confs': relConfirm,
      if (relNota != null) 'rel_nota': relNota,
    };
  }
}
