import 'package:get/get.dart';

import 'services/native_platform.service.dart';
import 'services/shared_preferences.service.dart';

class AppBindings implements Bindings {
  const AppBindings();

  @override
  void dependencies() {
    SharedPreferencesService.init();
    NativePlatformService.handlePlatformChannelMethods();
  }
}
