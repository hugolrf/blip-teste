import 'dart:async';

import 'package:blip_sdk/blip_sdk.dart';
import 'package:get/get.dart';

import '../listeners/message.listener.dart';
import '../models/base_authentication.model.dart';
import '../models/connection.model.dart';
import '../models/plain_auth.model.dart';

class ClientController extends GetxController {
  ClientController() {
    initController();
  }

  final connection = Connection();
  final String id = guid();
  StreamController<Session> _sessionFailedHandler = StreamController<Session>();
  StreamController<Session> _sessionFinishedHandler =
      StreamController<Session>();
  StreamController<Session> onAuthSessionFailed = StreamController<Session>();
  StreamController<Session> onAuthSessionFinished = StreamController<Session>();
  void Function()? removeSessionFailedHandler;
  void Function()? removeSessionFinishedHandler;
  String? ownerIdentity;
  bool hasMessages = false;

  MessageListener messageListener = MessageListener();
  StreamController<Notification> notificationListener =
      StreamController<Notification>();
  void Function()? removeMessageListener;
  void Function()? removeNotificationListener;

  late Client client;

  String get userIdentity => client.clientChannel.localNode?.name ?? id;

  void initController() {
    client = _clientInstance(PlainAuth(identity: id, password: ''));
  }

  void _initListeners() {
    _sessionFailedHandler.stream.listen((session) {
      if (session.state == SessionState.failed) {
        if (session.reason?.code == 13) {
          onAuthSessionFailed.sink.add(session);
        }
      }
    });

    _sessionFinishedHandler.stream.listen((session) async {
      if (session.state == SessionState.finished) {
        onAuthSessionFinished.sink.add(session);
      }
    });

    messageListener.listen(ownerIdentity, () => userIdentity);
  }

  Client _clientInstance(
    final BaseAuthentication auth,
  ) {
    final builder = ClientBuilder(transport: WebSocketTransport())
        .withEcho(true)
        .withNotifyConsumed(true)
        .withRoutingRule(RoutingRule.identity)
        .withDomain(connection.domain)
        .withHostName(connection.hostName)
        .withPort(connection.port);

    final client = auth.build(builder).build();

    if (removeSessionFailedHandler != null) {
      _sessionFailedHandler.close();
      removeSessionFailedHandler!();
      _sessionFailedHandler = StreamController<Session>();
    }

    if (removeSessionFinishedHandler != null) {
      _sessionFinishedHandler.close();
      removeSessionFinishedHandler!();
      _sessionFinishedHandler = StreamController<Session>();
    }

    if (removeMessageListener != null) {
      messageListener.listener.close();
      removeMessageListener!();
      messageListener = MessageListener();
    }

    if (removeNotificationListener != null) {
      notificationListener.close();
      removeNotificationListener!();
      notificationListener = StreamController<Notification>();
    }

    removeSessionFailedHandler =
        client.addSessionFailedHandlers(_sessionFailedHandler);
    removeSessionFinishedHandler =
        client.addSessionFinishedHandlers(_sessionFinishedHandler);

    removeMessageListener = client.addMessageListener(messageListener.listener);
    removeNotificationListener =
        client.addNotificationListener(notificationListener);

    _initListeners();

    return client;
  }

  void setClient(
    final BaseAuthentication auth,
  ) {
    //TODO: Check the need to store these params in state.
    client = _clientInstance(auth);
  }

  Future<void> disconnect() async {
    client.listening = false;
    onAuthSessionFailed.close();
    onAuthSessionFailed = StreamController<Session>();
    onAuthSessionFinished.close();
    onAuthSessionFinished = StreamController<Session>();
    await client.close();
  }
}
