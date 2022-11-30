import 'package:blip_sdk/blip_sdk.dart';
import 'package:get/get.dart' hide Node;

import '../app.config.dart';
import '../constants/message_content_type.dart';
import '../services/blip.service.dart';
import '../services/get.service.dart';

abstract class MediaProcessor {
  static final _clientController = GetService.findClient();
  static final _config = AppConfig.of(Get.context!)!;

  static Future<Command> getMediaUploadUri() =>
      _clientController.client.media.getUploadToken(secure: true);

  static Future<String> refreshContentUri(String uri) async {
    final command = await BlipService.sendCommand(
      Command(
        method: CommandMethod.set,
        to: Node.parse('postmaster@${_config.mediaDomain}'),
        uri: '/refresh-media-uri',
        type: MessageContentType.textPlain,
        resource: uri,
      ),
    );

    return command.resource as String;
  }
}
