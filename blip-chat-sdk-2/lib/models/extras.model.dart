class Extras {
  // blipchat-domains
  final List<String> domains;
  // blipchat-app-key
  final String? appKey;
  // tenantId
  final String? tenantId;
  // blipchat-display-name
  final String? displayName;
  // blipchat-receive-files
  final bool receiveFiles;
  // blipchat-hide-powered
  final bool hidePowered;
  // blipchat-components-color
  final String? componentsColor;
  // blipchat-chat-color
  final String? chatColor;

  const Extras({
    this.domains = const [],
    this.appKey,
    this.tenantId,
    this.componentsColor,
    this.displayName,
    this.receiveFiles = false,
    this.hidePowered = false,
    this.chatColor,
  });

  Extras.fromJson(Map<String, dynamic> json)
      : domains = (json['blipchat-domains'] ?? '').split(','),
        appKey = json['blipchat-app-key'],
        tenantId = json['tenantId'],
        displayName = json['blipchat-display-name'],
        receiveFiles = (json['blipchat-receive-files'] as String? ?? 'false')
                .toLowerCase() ==
            'true',
        hidePowered = (json['blipchat-hide-powered'] as String? ?? 'false')
                .toLowerCase() ==
            'true',
        componentsColor = json['blipchat-components-color'],
        chatColor = json['blipchat-chat-color'];
}
