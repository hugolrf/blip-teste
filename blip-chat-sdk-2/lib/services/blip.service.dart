import 'dart:math';

import 'package:blip_sdk/blip_sdk.dart';

import 'get.service.dart';

abstract class BlipService {
  // static final _appConfig = AppConfig.of(Get.context!)!;
  // static final int _defaultTimeout = _appConfig.defaultClientTimeOut;
  static const int _defaultTimeout = 61000;

  static final _clientController = GetService.findClient();

  static Future<Command> sendCommand(Command command, {int? timeout}) async {
    timeout ??= _defaultTimeout;

    return await _clientController.client
        .sendCommand(command, timeout: timeout);
  }

  static Future<Command> sendCommandWithRetry(Command command,
      {commandTryCount = 0, maxTry = 1}) async {
    if (commandTryCount > maxTry) {
      throw Exception(
          'Could not successfully send command for uri ${command.uri}. Max retries count of $maxTry reached. Please refresh the page.');
    }

    try {
      return await sendCommand(command);
    } catch (e) {
      commandTryCount++;
      num timeout = 100 * pow(2, commandTryCount);
      return Future.delayed(Duration(milliseconds: timeout.round()), () async {
        return await sendCommandWithRetry(command);
      });
    }
  }

  static void sendNotification(Notification notification) {
    _clientController.client.sendNotification(notification);
  }

  static bool isFailedCommand(LimeException error) {
    final timeout = error.reason.code == ReasonCodes.timeoutError;
    return error.status == CommandStatus.failure || timeout;
  }

  static checkConnection() async {
    bool isConnected = _clientController.client.listening;
    if (!isConnected) {
      return;
    }
    try {
      await sendCommand(Command(method: CommandMethod.get, uri: '/ping'),
          // timeout: _appConfig.pingTimeout,
          timeout: 6000);
    } on LimeException catch (error) {
      if (error.reason.code == ReasonCodes.timeoutError) {
        await _clientController.disconnect();
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  static void sendMessage(Message message) {
    _clientController.client.sendMessage(message);
  }
}
