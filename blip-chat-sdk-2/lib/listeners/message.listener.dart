import 'dart:async';
import 'dart:convert';

import 'package:blip_sdk/blip_sdk.dart';

import '../constants/message_content_type.dart';
import '../enums/chat_state_types.enum.dart';
import '../models/blip_message.model.dart';

class MessageListener {
  final listener = StreamController<Message>();

  StreamController<BlipMessage> filteredMessagelistener =
      StreamController<BlipMessage>.broadcast();

  void listen(String? ownerIdentity, String Function() userIdentity) {
    listener.stream.listen((Message message) async {
      // Redirect Messages should be ignored
      // Ticket Messages should be ignored
      if ([
        MessageContentType.redirect,
        MessageContentType.ticket,
      ].any((x) => x == message.type)) {
        return;
      }

      // check if messages comes from current chatbot or, if is an echo, it was
      // send from this user to the current chatbot
      final idFrom = message.from?.name;
      final idTo = message.to?.name;

      if ((idFrom?.isNotEmpty ?? false) && (idTo?.isNotEmpty ?? false)) {
        if (idFrom!.toLowerCase() == ownerIdentity!.toLowerCase() ||
            (message.metadata?['#message.echo'] != null &&
                idTo!.toLowerCase() == ownerIdentity.toLowerCase() &&
                idFrom.toLowerCase() == userIdentity().toLowerCase() &&
                (message.type != MessageContentType.chatState ||
                    (message.type == MessageContentType.chatState &&
                        (message.content['state'] !=
                                ChatStateTypes.composing.name &&
                            message.content['state'] !=
                                ChatStateTypes.paused.name))))) {
          filteredMessagelistener.add(processMessage(message));
        }
      }

      return;
    });
  }

  BlipMessage processMessage(Message message) {
    if (message.metadata?['#blip.payload.content'] != null ||
        message.metadata?['#blip.payload.text'] != null) {
      message = Message.fromJson(
        {
          ...message.toJson(),
          'type': message.metadata?['#blip.payload.type'] ??
              MessageContentType.textPlain,
          'content': message.metadata?['#blip.payload.content'] ??
              message.metadata?['#blip.payload.text'],
        },
      );

      if (message.type != MessageContentType.textPlain) {
        try {
          message.content = jsonEncode(message.content);
        } catch (e) {
          print(e);
        }
      }
    }

    return BlipMessage.fromJson(message.toJson());
  }
}
