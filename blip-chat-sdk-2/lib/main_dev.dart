import 'dart:async';

import 'package:flutter/material.dart';

import 'app.config.dart';
import 'blip_chat_app.dart';
import 'errors/handler.error.dart';

void main() {
  runZonedGuarded(() async {
    const configuredApp = AppConfig(
      appName: 'Blip Chat - Dev',
      hostName: 'hmg-ws.0mn.io',
      hostNameTenantDefault: 'hmg-ws.0mn.io',
      child: BlipChatApp(),
    );

    WidgetsFlutterBinding.ensureInitialized();

    // await SegmentService.init(configuredApp.segmentApiKey);

    // await SentryFlutter.init(
    //   (options) {
    //     options.dsn = 'https://feba9934002e442a9234e8627e027ee6@o1174857.ingest.sentry.io/6271233';
    //     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    //     // We recommend adjusting this value in production.
    //     options.tracesSampleRate = 1.0;
    //   },
    //   appRunner: () => runApp(configuredApp),
    // );
    runApp(configuredApp);
  }, ErrorHandler.onError);
}
