import 'dart:convert';
import 'dart:ui';
import 'package:dart_date/dart_date.dart';
import 'package:timeago/timeago.dart' as timeago;

abstract class UtilsService {
  static Map<String, dynamic> decodeBlipKey(String key) {
    final stringToBase64 = utf8.fuse(base64);
    final data = stringToBase64.decode(key);
    Map<String, dynamic> ownerData;

    try {
      ownerData = jsonDecode(data);
    } catch (e) {
      final result = data.split(':');
      ownerData = {'ownerIdentity': result[0], 'ownerKey': result[1]};
    }

    return ownerData;
  }

  static String getRelativeDate({String? date}) {
    final dateParse = DateTime.parse(date!).local;
    final today = DateTime.now().utc;
    if (today.isSameDay(dateParse)) {
      return getHourWithoutSeconds(dateParse);
    } else {
      return timeago.format(dateParse, allowFromNow: true, locale: 'PtBr');
    }
  }

  static String getHourWithoutSeconds(DateTime date) {
    return date.format('HH:mm');
  }

  static String getHourWithSeconds(DateTime date) {
    return date.format('HH:mm:ss');
  }

  static String getFullDateWritten(DateTime date) {
    ///TODO: Check locale
    var writtenDate = date.format('yMMMd', 'pt_BR');
    writtenDate = '$writtenDate ${getHourWithoutSeconds(date)}';
    return writtenDate;
  }

  static String getChatDisplayDate({String? date}) {
    final dateParse = DateTime.parse(date!).local;
    final today = DateTime.now().utc;
    if (today.isSameDay(dateParse)) {
      return getHourWithoutSeconds(dateParse);
    } else {
      return getFullDateWritten(dateParse);
    }
  }

  static DateTime getNowAddTime(int addMilliseconds) {
    final now = DateTime.now().utc;
    now.add(Duration(milliseconds: addMilliseconds));
    return now;
  }

  static Locale? getLocaleFromLanguageTag(String? languageTag) {
    if (languageTag?.isEmpty ?? true) return null;

    final result = languageTag!.split('-');
    final languageCode = result[0];
    String? countryCode;

    if (result.length > 1) {
      countryCode = result[1];
    }
    return Locale(languageCode, countryCode);
  }
}
