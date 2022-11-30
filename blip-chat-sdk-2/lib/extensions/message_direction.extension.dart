import 'package:flutter/foundation.dart';

import '../enums/message_direction.enum.dart';

extension MessageDirectionExtension on MessageDirection {
  MessageDirection getValue(String value) => MessageDirection.values.firstWhere(
      (e) => describeEnum(e) == value.toLowerCase(),
      orElse: () => MessageDirection.unknown);
}
