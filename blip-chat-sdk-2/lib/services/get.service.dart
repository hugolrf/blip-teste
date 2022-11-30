import 'package:get/get.dart';

import '../controllers/chat.controller.dart';
import '../controllers/client.controller.dart';
import '../enums/getx_tag.enum.dart';

abstract class GetService {
  static T find<T>({String? tag, T Function()? fallback}) {
    try {
      return Get.find<T>(tag: tag);
    } catch (e) {
      if (fallback != null) {
        return Get.put(fallback(), tag: tag);
      }

      rethrow;
    }
  }

  static ClientController findClient() => find<ClientController>(
      tag: GetxTag.clientController.name, fallback: () => ClientController());

  static Future<bool> deleteClient() =>
      Get.delete<ClientController>(tag: GetxTag.clientController.name);

  static ChatController findChat() => find<ChatController>(
      tag: GetxTag.chatController.name, fallback: () => ChatController());

  static Future<bool> deleteChat() =>
      Get.delete<ChatController>(tag: GetxTag.chatController.name);
}
