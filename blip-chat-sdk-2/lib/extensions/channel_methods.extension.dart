import 'package:flutter/foundation.dart';

import '../enums/channel_methods.enum.dart';

extension ChannelMethodsExtension on ChannelMethods {
  ChannelMethods getValue(String value) => ChannelMethods.values.firstWhere(
      (e) => describeEnum(e).toLowerCase() == value.toLowerCase(),
      orElse: () => ChannelMethods.unknown);
}
