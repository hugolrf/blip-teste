import 'package:blip_ds/blip_ds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/owner_display_data.model.dart';
import '../models/welcome_data.model.dart';
import '../services/message.service.dart';
import '../widgets/buttons/primary_button.widget.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.data,
    required this.ownerDisplayData,
  });

  final WelcomeData data;
  final OwnerDisplayData ownerDisplayData;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DSUserAvatar(
                        uri: ownerDisplayData.photo,
                        radius: 50,
                      ),
                      const SizedBox(height: 5),
                      DSHeadlineSmallText(ownerDisplayData.name),
                      DSCaptionText(ownerDisplayData.status.name.capitalizeFirst!),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: DSBodyText(
                          data.greetingMessage,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: data.buttonLabel,
                        onPressed: () {
                          MessageService.sendTextMessage(data.buttonMessage);
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
