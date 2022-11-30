import 'package:blip_sdk/blip_sdk.dart';

import '../services/account.service.dart';
import '../services/get.service.dart';
import 'base_authentication.model.dart';

class PlainAuth implements BaseAuthentication {
  PlainAuth({
    required this.identity,
    required this.password,
    bool? useMtls,
  }) : useMtls = useMtls ?? false;

  String identity;
  String password;

  @override
  bool useMtls;

  @override
  AuthenticationScheme get type => AuthenticationScheme.plain;

  PlainAuth.fromJson(Map<String, dynamic> json)
      : identity = json['identity'],
        password = json['password'],
        useMtls = json['useMtls'];

  @override
  ClientBuilder build(ClientBuilder client) =>
      client.withIdentifier(identity).withPassword(password).withMtls(useMtls);

  @override
  Future<void> connect() async {
    await AccountService.connectUser(this);
  }

  @override
  void setClient() {
    final clientController = GetService.findClient();

    clientController.setClient(this);
  }
}
