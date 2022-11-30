import 'package:flutter/widgets.dart';

class AppConfig extends InheritedWidget {
  final String appName;

  final String hostName;
  final String hostNameTenantDefault;
  final String domain;
  final String ownerDomain;
  final String blipDomain;
  final String mediaDomain;
  final int port;
  final bool showMessageStatus;
  final bool removeDuplicatedMessages;
  final List<String> allowedDomains;

  const AppConfig({
    Key? key,
    required this.appName,
    required this.hostName,
    required this.hostNameTenantDefault,
    this.domain = '0mn.io',
    this.ownerDomain = 'msging.net',
    this.blipDomain = 'blip.ai',
    this.mediaDomain = 'media.msging.net',
    this.port = 443,
    this.showMessageStatus = true,
    this.removeDuplicatedMessages = false,
    this.allowedDomains = const [
      "https://hmg-chat.blip.ai",
      "https://chat.blip.ai",
      "https://blipchatcommon.azurewebsites.net",
      "blip.ai",
      "preview.blip.ai",
      "portal.blip.ai",
      "debug.blip.ai",
      "hmg-preview.blip.ai",
      "hmg-portal.blip.ai",
      "hmg-debug.blip.ai",
    ],
    required Widget child,
  }) : super(key: key, child: child);

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
