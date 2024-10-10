class EvmNode {
  EvmNode({
    required this.url,
    this.guiAuth = false,
  });
  final String url;
  final bool guiAuth;

  Map<String, dynamic> toJson() => {
        'url': url,
        'gui_auth': guiAuth,
      };

  factory EvmNode.fromJson(Map<String, dynamic> json) {
    return EvmNode(
      url: json['url'] as String,
      guiAuth: json['gui_auth'] as bool? ?? false,
    );
  }
}
