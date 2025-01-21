import 'package:komodo_defi_types/komodo_defi_types.dart';

class LightningPayment {
  LightningPayment({
    required this.type,
    this.invoice,
    this.destination,
    this.amountInMsat,
    this.expiry,
  });

  factory LightningPayment.fromJson(Map<String, dynamic> json) {
    return LightningPayment(
      type: json.value<String>('type'),
      invoice: json.valueOrNull<String?>('invoice'),
      destination: json.valueOrNull<String?>('destination'),
      amountInMsat: json.valueOrNull<int?>('amount_in_msat'),
      expiry: json.valueOrNull<int?>('expiry'),
    );
  }
  final String type;
  final String? invoice;
  final String? destination;
  final int? amountInMsat;
  final int? expiry;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (invoice != null) json['invoice'] = invoice;
    if (destination != null) json['destination'] = destination;
    if (amountInMsat != null) json['amount_in_msat'] = amountInMsat;
    if (expiry != null) json['expiry'] = expiry;
    return json;
  }
}
