class AddressFormat {
  const AddressFormat({
    required this.format,
    required this.network,
  });

  final String format;
  final String network;

  Map<String, dynamic> toJson() => {
        'format': format,
        'network': network,
      };
}
