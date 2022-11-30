import 'dart:io';
import 'package:blip_sdk/blip_sdk.dart';
import 'package:flutter/services.dart';

abstract class ErrorHandler {
  // static void identifyUser(User user) => Sentry.configureScope(
  //       (scope) => scope.user = SentryUser(
  //         email: user.email,
  //         extras: user.toJson(),
  //       ),
  //     );

  // static void trackException(
  //   final Object exception, {
  //   final StackTrace? stackTrace,
  //   Map<String, dynamic>? properties,
  //   final Ticket? ticket,
  // }) {
  //   if (ticket != null && exception is LimeException) {
  //     if (exception.reason.code == ReasonCodes.commandResourceNotFound) {
  //       return;
  //     }
  //   }

  //   final _accountController = GetService.find<AccountController>();

  //   if (_accountController.me.value != null) {
  //     identifyUser(_accountController.me.value!);
  //   }

  //   if (properties != null) {
  //     Sentry.configureScope(
  //       (scope) {
  //         if (ticket != null) {
  //           properties = {
  //             ...properties!,
  //             'ticketId': ticket.id,
  //             'ticketSequentialId': ticket.sequentialId,
  //             'ownerIdentity': ticket.ownerIdentity,
  //           };
  //         }
  //         properties?.forEach((key, value) => scope.setTag(key, value));

  //         Sentry.captureException(exception, stackTrace: stackTrace);
  //       },
  //     );
  //   } else {
  //     Sentry.captureException(exception, stackTrace: stackTrace);
  //   }
  // }

  static onError(Object exception, StackTrace stackTrace) {
    // AppFlushbar(
    //   message: getErrorMessage(exception),
    //   icon: const Icon(
    //     Icons.error_outline,
    //     size: 28.0,
    //     color: Colors.redAccent,
    //   ),
    //   leftBarIndicatorColor: Colors.redAccent,
    // ).show(Get.context!);

    print(exception);

    // trackException(exception, stackTrace: stackTrace);
  }

  static String? getErrorMessage(Object error) {
    if (error is HttpException) {
      return error.message;
    } else if (error is PlatformException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else if (error is LimeException) {
      return '${error.reason.code} - ${error.reason.description}';
    }

    return 'Oooooops. Ocorreu um erro desconhecido. Pedimos desculpas pelo inconveniente!';
  }
}
