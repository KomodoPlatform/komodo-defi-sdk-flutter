class SlpActivationParams {
  SlpActivationParams({this.requiredConfirmations});
  final int? requiredConfirmations;

  Map<String, dynamic> toJson() => {
    'required_confirmations': requiredConfirmations,
  };
}
