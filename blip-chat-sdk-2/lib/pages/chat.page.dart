import 'package:blip_ds/blip_ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../services/get.service.dart';
import '../themes/app_theme.model.dart';
import '../widgets/chat/chat_footer.widget.dart';
import '../widgets/chat/chat_header.widget.dart';
import 'loading_chat.page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = GetService.findChat();

  @override
  void dispose() {
    GetService.deleteChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const LoadingChatPage()
          : Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              appBar: ChatHeader(),
              body: KeyboardDismissOnTap(
                child: Column(
                  children: [
                    Expanded(
                      child: DSGroupCard(
                        documents:
                            controller.formattedMessages.map((x) => x).toList(),
                        isComposing: controller.isComposing.value,
                        showMessageStatus: controller.config.showMessageStatus,
                        onSelected: controller.onSelectedOption,
                        onOpenLink: controller.onOpenLink,
                        style: DSMessageBubbleStyle(
                          sentBackgroundColor: AppTheme.sentBubbleColor,
                          receivedBackgroundColor: AppTheme.receivedBubbleColor,
                          pageBackgroundColor: AppTheme.backgroundColor,
                        ),
                        avatarConfig: controller.avatarConfig,
                        onInfinitScroll: controller.onInfinitScroll,
                      ),
                    ),
                    ChatFooter(),
                  ],
                ),
              ),
            ),
    );
  }
}
