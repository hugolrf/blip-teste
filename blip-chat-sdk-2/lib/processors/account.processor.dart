import 'package:blip_sdk/blip_sdk.dart';
import 'package:get/get.dart' hide Node;

import '../app.config.dart';
import '../enums/status.enum.dart';
import '../models/user.model.dart';
import '../services/blip.service.dart';
import '../services/get.service.dart';

abstract class AccountProcessor {
  static final _clientController = GetService.findClient();
  static final _config = AppConfig.of(Get.context!)!;

  static Future<Command> getOwner(final String id, {String? domain}) {
    domain ??= _config.ownerDomain;
    return BlipService.sendCommand(Command(
      method: CommandMethod.get,
      to: Node.parse('postmaster@$domain'),
      uri: 'lime://$domain/accounts/$id',
    ));
  }

  static Future<Command> create(String id, {resource}) async {
    return BlipService.sendCommand(
      Command(
        method: CommandMethod.set,
        from: Node.parse('$id@${_config.domain}/default'),
        pp: _clientController.client.clientChannel.localNode,
        type: 'application/vnd.lime.account+json',
        uri: '/account',
        resource: resource,
      ),
    );
  }

  static Future<Command> getUser() async {
    return BlipService.sendCommand(
      Command(
        method: CommandMethod.get,
        uri: '/account',
      ),
    );
  }

  static Future<Command> setUser(User account) async {
    return BlipService.sendCommand(
      Command(
        method: CommandMethod.merge,
        type: 'application/vnd.lime.account+json',
        uri: '/account',
        resource: account.toJson(),
      ),
    );
  }

  static Future<Command> welcomeMessage(String id) {
    return BlipService.sendCommand(
      Command(
        method: CommandMethod.get,
        to: Node.parse('postmaster@${_config.ownerDomain}'),
        uri: 'lime://$id@${_config.ownerDomain}/profile/greeting',
      ),
    );
  }

  static Future<Command> startButton(String id) {
    return BlipService.sendCommand(
      Command(
        method: CommandMethod.get,
        to: Node.parse('postmaster@${_config.ownerDomain}'),
        uri: 'lime://$id@${_config.ownerDomain}/profile/get-started',
      ),
    );
  }

  static Future<Command> startButtonLabel(String id) {
    return BlipService.sendCommand(
      Command(
        method: CommandMethod.get,
        to: Node.parse('postmaster@${_config.ownerDomain}'),
        uri: 'lime://$id@${_config.ownerDomain}/profile/get-started-label',
      ),
    );
  }

  static Future<Status> status(String id) async {
    try {
      await BlipService.sendCommand(
        Command(
          method: CommandMethod.get,
          uri: '/ping',
          to: Node.parse('$id@${_config.ownerDomain}'),
        ),
      );

      return Status.online;
    } catch (_) {
      return Status.offline;
    }
  }
}
