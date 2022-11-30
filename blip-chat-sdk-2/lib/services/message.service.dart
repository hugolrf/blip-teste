import 'package:blip_sdk/blip_sdk.dart';
import 'package:get/get.dart' hide Node;

import '../app.config.dart';
import '../constants/message_content_type.dart';
import 'blip.service.dart';
import 'get.service.dart';

abstract class MessageService {
  static final _clientController = GetService.findClient();
  static final _config = AppConfig.of(Get.context!)!;
  static final Map<String, dynamic> customMetadata = {};

  static void sendChatState(String state) {
    final message = Message(
      content: {'state': state},
      type: MessageContentType.chatState,
      to: Node.parse(
          '${_clientController.ownerIdentity}@${_config.ownerDomain}'),
      metadata: customMetadata,
    );
    BlipService.sendMessage(message);
  }

  static void sendMessage(
    String type,
    dynamic content, {
    Map<String, dynamic>? metadata,
  }) {
    final message = Message(
      content: content,
      type: type,
      to: Node.parse(
          '${_clientController.ownerIdentity}@${_config.ownerDomain}'),
      metadata: {...(metadata ?? {}), ...customMetadata},
    );
    BlipService.sendMessage(message);
  }

  static void sendTextMessage(
    String content, {
    Map<String, dynamic>? metadata,
  }) {
    final message = Message(
      content: content,
      type: MessageContentType.textPlain,
      to: Node.parse(
          '${_clientController.ownerIdentity}@${_config.ownerDomain}'),
      metadata: {...(metadata ?? {}), ...customMetadata},
    );
    BlipService.sendMessage(message);
  }

  static void sendSensitiveMessage(
    Map<String, dynamic> content, {
    Map<String, dynamic>? metadata,
  }) {
    final message = Message(
      content: content,
      type: MessageContentType.sensitive,
      to: Node.parse(
          '${_clientController.ownerIdentity}@${_config.ownerDomain}'),
      metadata: {...(metadata ?? {}), ...customMetadata},
    );
    BlipService.sendMessage(message);
  }

  static void sendMediaLinkMessage(
    Map<String, dynamic> content, {
    Map<String, dynamic>? metadata,
  }) {
    final message = Message(
      content: content,
      type: MessageContentType.mediaLink,
      to: Node.parse(
          '${_clientController.ownerIdentity}@${_config.ownerDomain}'),
      metadata: {...(metadata ?? {}), ...customMetadata},
    );
    BlipService.sendMessage(message);
  }
}
