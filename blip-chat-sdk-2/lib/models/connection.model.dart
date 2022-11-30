import 'package:get/get.dart';

import '../app.config.dart';

class Connection {
  late String domain;
  late String hostName;
  late int port;
  String? tenant;

  Connection() {
    final config = AppConfig.of(Get.context!)!;

    domain = config.domain;
    hostName = config.hostName;
    port = config.port;
  }
}
