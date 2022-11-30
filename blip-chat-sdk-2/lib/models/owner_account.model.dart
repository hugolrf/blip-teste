import 'package:blip_sdk/blip_sdk.dart';

import 'extras.model.dart';

class OwnerAccount {
  String name;
  Identity identity;
  String email;
  Uri? photoUri;
  Extras extras;
  String? source;
  DateTime? creationDate;

  OwnerAccount({
    required this.name,
    required this.identity,
    required this.email,
    this.photoUri,
    this.extras = const Extras(),
    this.source,
    this.creationDate,
  });

  OwnerAccount.fromJson(Map<String, dynamic> json)
      : name = json['fullName'],
        identity = Identity.parse(json['identity']),
        email = json['email'],
        photoUri = Uri.tryParse(json['photoUri']),
        extras = Extras.fromJson(json['extras'] ?? const {}),
        source = json['source'],
        creationDate = DateTime.tryParse(json['creationDate']);
}
