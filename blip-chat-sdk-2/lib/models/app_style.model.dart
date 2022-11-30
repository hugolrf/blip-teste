import 'dart:ui';

import 'package:blip_ds/blip_ds.dart';

import '../extensions/hex_color.extension.dart';

class AppStyle {
  Color primaryColor;
  Color sentBubbleColor;
  Color receivedBubbleColor;
  Color backgroundColor;
  bool overrideOwnerColors;
  bool showOwnerAvatar;
  bool showUserAvatar;

  AppStyle({
    this.primaryColor = DSColors.primaryNight,
    this.sentBubbleColor = DSColors.neutralDarkCity,
    this.receivedBubbleColor = DSColors.neutralLightSnow,
    this.backgroundColor = DSColors.neutralLightBox,
    this.overrideOwnerColors = false,
    this.showOwnerAvatar = true,
    this.showUserAvatar = true,
  });

  AppStyle.fromJson(Map<String, dynamic> json)
      : primaryColor = json['primary'] != null
            ? HexColor.fromHex(json['primary'])
            : DSColors.primaryNight,
        sentBubbleColor = json['sentBubble'] != null
            ? HexColor.fromHex(json['sentBubble'])
            : DSColors.neutralDarkCity,
        receivedBubbleColor = json['receivedBubble'] != null
            ? HexColor.fromHex(json['receivedBubble'])
            : DSColors.neutralLightSnow,
        backgroundColor = json['background'] != null
            ? HexColor.fromHex(json['background'])
            : DSColors.neutralLightBox,
        overrideOwnerColors = json['overrideOwnerColors'] ?? false,
        showOwnerAvatar = json['showOwnerAvatar'] ?? true,
        showUserAvatar = json['showUserAvatar'] ?? true;
}
