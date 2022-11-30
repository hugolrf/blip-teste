import 'package:blip_sdk/blip_sdk.dart';

import '../exceptions/missing_argument.exception.dart';
import '../services/account.service.dart';
import '../services/utils.service.dart';
import 'app_style.model.dart';
import 'base_authentication.model.dart';
import 'external_auth.model.dart';
import 'plain_auth.model.dart';
import 'sdk_account_properties.model.dart';

class SdkProperties {
  String key;
  BaseAuthentication auth;
  String ownerIdentity;
  String? hostName;
  SdkAccountProperties? account;
  AppStyle? style;

  SdkProperties({
    required this.key,
    required this.auth,
    String? ownerIdentity,
    this.hostName,
    this.account,
    this.style,
  }) : ownerIdentity =
            ownerIdentity ?? UtilsService.decodeBlipKey(key)['ownerIdentity'];

  factory SdkProperties.fromJson(Map<String, dynamic> json) {
    final String key = json['key'];
    final AuthenticationScheme type =
        AuthenticationScheme.unknown.getValue(json['type']);
    late final BaseAuthentication auth;
    final ownerIdentity = UtilsService.decodeBlipKey(key)['ownerIdentity'];

    switch (type) {
      case AuthenticationScheme.plain:
        final user = AccountService.createGuestUser(ownerIdentity);
        auth = PlainAuth(
          identity: user.identity,
          password: user.password,
          useMtls: json['useMtls'],
        );
        break;
      case AuthenticationScheme.external:
        if (json['token'] == null) {
          throw MissingArgumentException(
              'Param \'Token\' must be informed for \'External\' type',
              'token');
        } else if (json['issuer'] == null) {
          throw MissingArgumentException(
              'Param \'Issuer\' must be informed for \'External\' type',
              'issuer');
        }

        auth = ExternalAuth(
          token: json['token'],
          issuer: json['issuer'],
          useMtls: json['useMtls'],
        );
        break;
      default:
        throw MissingArgumentException(
            'Unknown Authentication type. Options must be: plain or external',
            'type');
    }

    return SdkProperties(
      key: key,
      auth: auth,
      ownerIdentity: ownerIdentity,
      hostName: json['hostName'],
      account: json['account'] != null
          ? SdkAccountProperties.fromJson(json['account'])
          : null,
      style: json['style'] != null ? AppStyle.fromJson(json['style']) : null,
    );
  }
}
