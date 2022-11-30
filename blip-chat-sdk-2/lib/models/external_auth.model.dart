import 'package:blip_sdk/blip_sdk.dart';

import '../services/account.service.dart';
import '../services/get.service.dart';
import 'base_authentication.model.dart';

class ExternalAuth implements BaseAuthentication {
  ExternalAuth({
    required this.token,
    required this.issuer,
    bool? useMtls,
  }) : useMtls = useMtls ?? false;

  final String token;
  final String issuer;

  @override
  bool useMtls;

  @override
  AuthenticationScheme get type => AuthenticationScheme.external;

  ExternalAuth.fromJson(Map<String, dynamic> json)
      : token = json['token'],
        issuer = json['issuer'],
        useMtls = json['useMtls'];

  @override
  ClientBuilder build(ClientBuilder client) =>
      client.withToken(token, issuer).withMtls(useMtls);

  @override
  Future<void> connect() async {
    await AccountService.connectUserWithExternal(this);
  }

  @override
  void setClient() {
    final clientController = GetService.findClient();

    clientController.setClient(this);
  }
}
