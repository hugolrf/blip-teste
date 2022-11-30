import 'dart:async';

import 'package:blip_ds/blip_ds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';

import '../../constants/message_content_type.dart';
import '../../enums/chat_state_types.enum.dart';
import '../../services/get.service.dart';
import '../../themes/app_theme.model.dart';

class ChatFooter extends StatelessWidget {
  ChatFooter({Key? key}) : super(key: key);

  final _chatController = GetService.findChat();

  @override
  Widget build(BuildContext context) => Obx(
        () {
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          const containerBorder = Border(
            top: BorderSide(
              width: 1,
              color: DSColors.neutralMediumWave,
            ),
          );

          if (_chatController.isClientOffline.value) {
            return Container(
              decoration: const BoxDecoration(
                color: DSColors.neutralLightWhisper,
                border: containerBorder,
              ),
              padding: EdgeInsets.fromLTRB(
                8,
                18,
                8,
                bottomPadding + 18,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DSBodyText(
                    'chat-messages.client-inactivity'.i18n(),
                  ),
                ],
              ),
            );
          }

          final keyboardOpen = _chatController.keyboardOpen.value;

          return Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              bottomPadding > 0 && !keyboardOpen ? bottomPadding : 8,
            ),
            decoration: const BoxDecoration(
              color: DSColors.neutralLightSnow,
              border: containerBorder,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_chatController.ownerAccount.extras.receiveFiles)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Obx(
                          () => DSAttachmentButton(
                            onPressed: _chatController.pickFile,
                            isLoading: _chatController.isUploadingFiles.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Obx(
                    () => DSTextFormField(
                      controller: _chatController.addMessageFieldController,
                      hint: 'chat-messages.input-hint'.i18n(),
                      textInputAction: TextInputAction.newline,
                      showEmojiButton: false,
                      obscureText: _chatController.messageType.value ==
                          MessageContentType.sensitive,
                      onChanged: (val) {
                        if (_chatController.currentChatState !=
                            ChatStateTypes.composing) {
                          _chatController
                              .sendChatState(ChatStateTypes.composing);
                        }

                        if (_chatController.debounce?.isActive ?? false) {
                          _chatController.debounce?.cancel();
                        }
                        _chatController.debounce =
                            Timer(const Duration(seconds: 2), () {
                          _chatController.sendChatState(ChatStateTypes.paused);
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: DSSendButton(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.isPrimaryColorLight
                        ? DSColors.neutralDarkCity
                        : DSColors.neutralLightSnow,
                    onPressed: () async {
                      await _chatController.sendMessage(
                          _chatController.addMessageFieldController.text);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
}
