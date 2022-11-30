import 'package:blip_sdk/blip_sdk.dart';

abstract class BaseAuthentication {
  final AuthenticationScheme type = AuthenticationScheme.unknown;
  final bool useMtls = false;

  ClientBuilder build(ClientBuilder client) => throw UnimplementedError();

  Future<void> connect() => throw UnimplementedError();

  void setClient() => throw UnimplementedError();
}
