import 'dart:ui';

import 'package:blip_sdk/blip_sdk.dart';

import '../services/utils.service.dart';

class User {
  User({
    required this.identity,
    this.fullName,
    this.email,
    this.photoUri,
    this.encryptMessageContent,
    this.alternativeAccount,
    this.culture,
    this.extras,
    this.creationDate,
  });

  /// The user identity, in the name@domain format.
  Identity identity;

  /// The user full name.
  String? fullName;

  /// The user e-mail address.
  String? email;

  /// The user photo URI.
  Uri? photoUri;

  /// Indicates if the content of messages from this account should be encrypted in the server.
  bool? encryptMessageContent;

  /// Alternative account address.
  Identity? alternativeAccount;

  /// Represents the person account culture info
  Locale? culture;

  /// Gets or sets the contact extra information.
  Map<String, dynamic>? extras;

  /// Indicates when the account was created.
  DateTime? creationDate;

  User.fromJson(Map<String, dynamic> json)
      : identity = Identity.parse(json['identity']),
        fullName = json['fullName'],
        email = json['email'],
        photoUri = (json['uri']?.isNotEmpty ?? false)
            ? Uri.tryParse(json['uri'])
            : null,
        encryptMessageContent = json['encryptMessageContent'],
        alternativeAccount = Identity.tryParse(json['alternativeAccount']),
        culture = UtilsService.getLocaleFromLanguageTag(json['culture']),
        extras = json['extras'],
        creationDate = (json['creationDate']?.isNotEmpty ?? false)
            ? DateTime.tryParse(json['creationDate'])
            : null;

  void setExtras(Map<String, dynamic> extras) {
    this.extras = {...(this.extras ?? {}), ...extras};
  }

  void setPushToken(String token) =>
      setExtras({'#inbox.forwardTo': '$token@firebase.gw.msging.net'});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['identity'] = identity.toString();

    if (fullName?.isNotEmpty ?? false) {
      json['fullName'] = fullName;
    }
    if (email?.isNotEmpty ?? false) {
      json['email'] = email;
    }

    if (photoUri != null) {
      json['photoUri'] = photoUri.toString();
    }

    if (encryptMessageContent != null) {
      json['encryptMessageContent'] = encryptMessageContent;
    }

    if (alternativeAccount != null) {
      json['alternativeAccount'] = alternativeAccount;
    }

    if (culture != null) {
      json['culture'] = culture!.toLanguageTag();
    }

    if (extras != null) {
      json['extras'] = extras;
    }

    if (creationDate != null) {
      json['creationDate'] = creationDate!.toIso8601String();
    }

    return json;
  }
}
