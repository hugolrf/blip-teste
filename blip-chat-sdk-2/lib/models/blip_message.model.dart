import 'package:blip_sdk/blip_sdk.dart';

import '../enums/message_direction.enum.dart';

class BlipMessage extends Message {
  BlipMessage({
    final String? id,
    final Node? from,
    final Node? to,
    final Node? pp,
    final Map<String, dynamic>? metadata,
    final String? type,
    final dynamic content,
    this.direction = MessageDirection.unknown,
    this.date,
    this.status = NotificationEvent.unknown,
  }) : super(
          id: id,
          from: from,
          to: to,
          pp: pp,
          metadata: metadata,
          type: type,
          content: content,
        );

  MessageDirection direction;
  DateTime? date;
  NotificationEvent status;

  factory BlipMessage.fromJson(Map<String, dynamic> json) {
    final message = Message.fromJson(json);

    return BlipMessage(
      id: message.id,
      from: message.from,
      to: message.to,
      pp: message.pp,
      metadata: message.metadata,
      type: message.type,
      content: message.content,
      date: DateTime.fromMillisecondsSinceEpoch(
          int.parse(message.metadata!['date_created'], radix: 10)),
      direction: (message.metadata?['#message.echo'] == 'true')
          ? MessageDirection.sent
          : MessageDirection.received,
      status: NotificationEvent.unknown.getValue(
        json['status'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'direction': direction.name,
        'date': date?.millisecondsSinceEpoch,
        'status': status,
      };
}
