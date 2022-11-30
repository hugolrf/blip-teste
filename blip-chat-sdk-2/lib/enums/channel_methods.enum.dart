export '../extensions/channel_methods.extension.dart';

enum ChannelMethods {
  onInit,
  onInitializing,
  onConnected,
  onReady,
  onMessageReceived,
  onMessageSend,
  onMessageViewed,
  onDisconnected,
  onServerClosed,
  onClosed,
  onError,
  unknown
}
