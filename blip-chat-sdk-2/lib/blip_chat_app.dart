import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';

import 'app.bindings.dart';
import 'app.config.dart';
import 'pages/chat.page.dart';

class BlipChatApp extends StatelessWidget {
  const BlipChatApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final result = Platform.localeName.split('_');
    final locale =
        Localizations.maybeLocaleOf(context) ?? Locale(result[0], result[1]);

    LocalJsonLocalization.delegate.directories = ['i18n'];

    final config = AppConfig.of(context)!;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: const AppBindings(),
      title: config.appName,
      locale: locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
        Locale('es', 'LA'),
      ],
      getPages: [
        GetPage(name: '/', page: () => const ChatPage()),
      ],
    );
  }
}
