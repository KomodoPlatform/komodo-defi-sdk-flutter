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
}
