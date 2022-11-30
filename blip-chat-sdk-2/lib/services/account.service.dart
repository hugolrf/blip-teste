import 'dart:async';
import 'dart:convert';

import 'package:blip_sdk/blip_sdk.dart';

import '../enums/shared_preferences_keys.enum.dart';
import '../models/external_auth.model.dart';
import '../models/plain_auth.model.dart';
import '../processors/account.processor.dart';
import 'get.service.dart';
import 'shared_preferences.service.dart';

const maxConnectUserTryCount = 10;

abstract class AccountService {
  static final _clientController = GetService.findClient();
  static int _connectionTryCount = 0;

  static Future<void> connectUser(PlainAuth auth) async {
    if (_connectionTryCount >= maxConnectUserTryCount) {
      throw 'Could not connect user ${auth.identity} - Max connection try count of $maxConnectUserTryCount reached. Please refresh the page.';
    }

    StreamSubscription<Session>? onAuthSessionFailedSub;

    final promise = Future.any([
      Future<void>(() {
        final c = Completer<void>();

        onAuthSessionFailedSub = _clientController.onAuthSessionFailed.stream
            .listen((session) async {
          if (session.reason?.code == 13) {
            await _clientController.disconnect();
            print('Connection closed ... Creating new account');
            await createNewAccount(auth);
            await connectNewUser(auth);
            c.complete();
            // } else {
            //   //TODO: Review the need of this line of code
            //   // _clientController.client.transport.onClose = () => {};
            //   _clientController.disconnect();

            //   return Future(() {
            //     final c = Completer();

            //     final timeout = 100 * pow(2, _connectionTryCount) as int;

            //     Future.delayed(
            //       Duration(milliseconds: timeout),
            //       () async {
            //         print('Retrying - Connect user ...');
            //         final newAccount = await connectUser(userData, connectionData: connectionData);
            //         c.complete(newAccount);
            //       },
            //     );

            //     return c.future;
            //   });
          }
        });

        return c.future;
      }),
      Future<void>(() async {
        final c = Completer<void>();
        _connectionTryCount++;

        auth.setClient();

        try {
          await _clientController.client.connect().then((value) {
            _connectionTryCount = 0;
            print('User connected with success: ${auth.identity}');
            onAuthSessionFailedSub?.cancel();
            c.complete();
          });
        } on InsecureSocketException catch (e) {
          /// TODO: Try to show DSToast
          // final alert = DSToastService(
          //   message: e.message,
          //   context: UtilsService.context,
          //   toastDuration: 4000,
          // );
          // alert.error();
          // ScaffoldMessenger.of(Get.context!)
          //     .showSnackBar(SnackBar(content: Text(e.message)));
          c.completeError(e);
        }

        // this.client.sessionPromise.catch((s) => {
        //   switch (s.reason.code) {
        //     case 11:
        //       console.log(
        //         'Closing current connection because another has been started',
        //       )
        //       break
        //     case 13:
        //       console.log('Invalid credentials, closing current connection...')
        //       break
        //   }
        // })
        return c.future;
      }),
    ]);

    return promise;
  }

  static Future connectUserWithExternal(ExternalAuth auth) async {
    if (_connectionTryCount >= maxConnectUserTryCount) {
      throw 'Could not connect user ${auth.token} - Max connection try count of $maxConnectUserTryCount reached. Please refresh the page.';
    }

    // StreamSubscription<Session>? onAuthSessionFailedSub;

    // final promise = Future.any([
    //   Future<User>(() {
    //     final c = Completer<User>();

    //     onAuthSessionFailedSub = _clientController.onAuthSessionFailed.stream
    //         .listen((session) async {
    //       if (session.reason?.code == 13) {
    //         await _clientController.disconnect();
    //         print('Connection closed ... Creating new account');
    //         final newAccount = await createNewAccount(user);
    //         await connectNewUser(newAccount);
    //         c.complete(newAccount);
    //         // } else {
    //         //   //TODO: Review the need of this line of code
    //         //   // _clientController.client.transport.onClose = () => {};
    //         //   _clientController.disconnect();

    //         //   return Future(() {
    //         //     final c = Completer();

    //         //     final timeout = 100 * pow(2, _connectionTryCount) as int;

    //         //     Future.delayed(
    //         //       Duration(milliseconds: timeout),
    //         //       () async {
    //         //         print('Retrying - Connect user ...');
    //         //         final newAccount = await connectUser(userData, connectionData: connectionData);
    //         //         c.complete(newAccount);
    //         //       },
    //         //     );

    //         //     return c.future;
    //         //   });
    //       }
    //     });

    //     return c.future;
    //   }),
    //   Future<User>(() async {

    //   }),
    // ]);

    // final c = Completer<User>();
    _connectionTryCount++;

    auth.setClient();

    try {
      await _clientController.client.connect().then((value) {
        _connectionTryCount = 0;
        print(value);
        // print('User connected with success: $user');
        // onAuthSessionFailedSub?.cancel();
        // c.complete(user);
      });
    } on InsecureSocketException catch (e) {
      /// TODO: Try to show DSToast
      // final alert = DSToastService(
      //   message: e.message,
      //   context: UtilsService.context,
      //   toastDuration: 4000,
      // );
      // alert.error();
      rethrow;
    }

    // this.client.sessionPromise.catch((s) => {
    //   switch (s.reason.code) {
    //     case 11:
    //       console.log(
    //         'Closing current connection because another has been started',
    //       )
    //       break
    //     case 13:
    //       console.log('Invalid credentials, closing current connection...')
    //       break
    //   }
    // })
    // return c.future;

    // return promise;
  }

  static Future<void> connectNewUser(PlainAuth auth) async {
    auth.setClient();
    try {
      await _clientController.client.connect();
      print('New user connected with success: ${auth.identity}');
    } catch (e) {
      print('Error connecting new user: ${auth.identity}');
      rethrow;
    }
  }

  static Future<void> createNewAccount(PlainAuth auth) async {
    try {
      auth.setClient();
      await _clientController.client.connectWithGuest(guid());
      print('Connected as guest');

      final accountData = {
        'userIdentity': auth.identity,
        'password': auth.password,
      };
      // final accountData = {
      //   'password': userData['userPassword'],
      //   'email': userData['email'] ?? userData['userEmail'],
      //   'fullName': userData['fullName'] ?? userData['userName'],
      //   ...userData,
      // };

      try {
        await AccountProcessor.create(auth.identity, resource: accountData);
        print('Create new account for user: ${auth.identity}');

        await _clientController.disconnect();
      } catch (e) {
        print('Error creating account: $e');
        // ErrorHandler.handle(e, 'AccountClient - Create account');
        rethrow;
      }
    } catch (e) {
      print('Error connecting as guest: $e');
      rethrow;
    }
  }

  static PlainAuth createGuestUser(String? ownerIdentity) {
    final prefs = SharedPreferencesService.prefs;
    final stringToBase64 = utf8.fuse(base64);

    final now = DateTime.now();
    var expiryDate = prefs.getInt(SharedPreferencesKeys.expiryDate.name) ??
        now.millisecondsSinceEpoch;

    if (DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(expiryDate))
            .inMinutes >
        5) {
      expiryDate = now.millisecondsSinceEpoch;
      prefs.remove(SharedPreferencesKeys.identifier.name);
      prefs.remove(SharedPreferencesKeys.password.name);
    }

    final id = prefs.getString(SharedPreferencesKeys.identifier.name) ?? guid();
    final pwd = prefs.getString(SharedPreferencesKeys.password.name) ?? guid();

    SharedPreferencesService.setPlainAuthPrefs(expiryDate, id, pwd);

    return PlainAuth(
      identity: '$id.$ownerIdentity',
      password: stringToBase64.encode(pwd),
    );
  }
}
