import 'package:blip_ds/blip_ds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../enums/status.enum.dart';
import '../../services/get.service.dart';
import '../../services/native_platform.service.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  ChatHeader({Key? key}) : super(key: key);

  final _chatController = GetService.findChat();

  @override
  Size get preferredSize => const Size(double.infinity, 56.0);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DSHeader(
        title: _chatController.ownerDisplayData.name,
        subtitle: (_chatController.isClientOffline.value
                ? Status.offline
                : Status.online)
            .name
            .capitalizeFirst,
        customerUri: _chatController.ownerDisplayData.photo,
        onBackButtonPressed: () {
          NativePlatformService.onClose();
        },
      ),
    );
  }
}
