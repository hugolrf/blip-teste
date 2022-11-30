import 'dart:convert';

import 'package:flutter/services.dart';

import '../enums/channel_methods.enum.dart';
import '../exceptions/missing_argument.exception.dart';
import '../models/sdk_properties.model.dart';
import 'get.service.dart';

abstract class NativePlatformService {
  static const _channelName = 'blip.sdk.chat.native/helper';
  static const _platform = MethodChannel(_channelName);

  static void handlePlatformChannelMethods() {
    _platform.setMethodCallHandler((methodCall) async {
      final chatController = GetService.findChat();

      switch (ChannelMethods.unknown.getValue(methodCall.method)) {
        case ChannelMethods.onInit:
          try {
            final data = jsonDecode(methodCall.arguments ?? '{}');

            onInitializing(data['key']);

            if (data['key'] == null) {
              throw MissingArgumentException(
                  'Param \'Key\' must be informed', 'key');
            } else if (data['type'] == null) {
              throw MissingArgumentException(
                  'Param \'Type\' must be informed', 'type');
            }

            final props = SdkProperties.fromJson(data);

            await chatController.initController(props);
          } on MissingArgumentException catch (e) {
            onError(e.toJson());
          } catch (e) {
            print(e);
          }

          break;
        default:
          break;
      }
    });
  }

  static void onInitializing(String? key) => _platfromSpecific(
      ChannelMethods.onInitializing,
      {'message': 'initializing Blip Chat with key: $key'});

  static void onConnect() => _platfromSpecific(
        ChannelMethods.onConnected,
        const {'message': 'User Connected with server successfully'},
      );

  static void onReady() => _platfromSpecific(
        ChannelMethods.onReady,
        const {'message': 'Chat is ready'},
      );

  static void onMessageReceived() => _platfromSpecific(
        ChannelMethods.onMessageReceived,
        const {'message': 'New message Received'},
      );

  static void onMessageSend() => _platfromSpecific(
        ChannelMethods.onMessageSend,
        const {'message': 'New message Sent'},
      );

  static void onMessageViewed() => _platfromSpecific(
        ChannelMethods.onMessageViewed,
        const {'message': 'Message was seen'},
      );

  static void onDisconnected() => _platfromSpecific(
        ChannelMethods.onDisconnected,
        const {'message': 'Chat disconnected'},
      );

  static void onServerClosed() => _platfromSpecific(
        ChannelMethods.onServerClosed,
        const {'message': 'Connection closed by the server'},
      );

  static void onClose() => _platfromSpecific(
        ChannelMethods.onClosed,
        const {'message': 'Chat closed by user'},
      );

  static void onError(Map<String, dynamic> e) => _platfromSpecific(
        ChannelMethods.onError,
        {'error': jsonEncode(e)},
      );

  static Future<T?> _platfromSpecific<T>(
      ChannelMethods method, Map<String, dynamic> payload) async {
    try {
      final result = await _platform.invokeMethod<T>(method.name, payload);

      return result;
    } on MissingPluginException catch (e) {
      print(e.message);
    } on PlatformException catch (e) {
      print(e.message);
      rethrow;
    }

    return null;
  }
}
