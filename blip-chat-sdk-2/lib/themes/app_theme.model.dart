import 'package:flutter/material.dart';

import '../models/app_style.model.dart';

abstract class AppTheme {
  static AppStyle _style = AppStyle();

  static Color get primaryColor => _style.primaryColor;
  static Color get sentBubbleColor => _style.sentBubbleColor;
  static Color get receivedBubbleColor => _style.receivedBubbleColor;
  static Color get backgroundColor => _style.backgroundColor;

  static bool? _isPrimaryColorLight;

  static bool get isPrimaryColorLight {
    _isPrimaryColorLight ??= primaryColor.computeLuminance() > 0.5;
    return _isPrimaryColorLight!;
  }

  static bool? _isBackgroundColorLight;

  static bool get isBackgroundColorLight {
    _isBackgroundColorLight ??= backgroundColor.computeLuminance() > 0.5;
    return _isBackgroundColorLight!;
  }

  static void setStyle(AppStyle style) => _style = style;
}
