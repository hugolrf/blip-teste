import 'package:blip_sdk/blip_sdk.dart';
import 'package:get/get.dart' hide Node;

import '../app.config.dart';
import '../services/blip.service.dart';
import '../services/get.service.dart';

const _take = 50;

class MessageProcessor {
  static final _clientController = GetService.findClient();
  static final _config = AppConfig.of(Get.context!)!;

  static Future<Command> getMessages(
      String id, String? messageId, DateTime? storageDate) {
    if (storageDate != null && messageId != null) {
      return BlipService.sendCommand(
        Command(
          method: CommandMethod.get,
          uri:
              '/threads/${Uri.encodeFull('$id@${_config.ownerDomain}')}?messageId=$messageId&storageDate=${storageDate.toIso8601String()}&\$take=$_take&direction=desc&refreshExpiredMedia=true',
        ),
      );
    } else if (messageId != null) {
      return BlipService.sendCommand(
        Command(
          method: CommandMethod.get,
          uri:
              '/threads/${Uri.encodeFull('$id@${_config.ownerDomain}')}?messageId=$messageId&\$take=$_take&direction=desc&refreshExpiredMedia=true',
        ),
      );
    } else {
      return BlipService.sendCommand(
        Command(
          method: CommandMethod.get,
          uri:
              '/threads/${Uri.encodeFull('$id@${_config.ownerDomain}')}?\$take=$_take&direction=desc&refreshExpiredMedia=true',
        ),
      );
    }
  }

  static void send(
    Message message, {
    Map<String, dynamic>? customMessageMetadata,
    sendId = true,
  }) {
    var metadata = message.metadata ?? {};

    if (customMessageMetadata != null) {
      metadata = {...metadata, ...customMessageMetadata};
    }

    final targetMessage = Message(
      id: sendId ? guid() : null,
      to: Node.parse(
          '${_clientController.ownerIdentity}@${_config.ownerDomain}'),
      type: message.type,
      content: message.content,
      metadata: metadata,
    );

    BlipService.sendMessage(targetMessage);
  }
}
