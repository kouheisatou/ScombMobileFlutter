import 'dart:typed_data';
import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:intl/intl.dart';
import 'package:scomb_mobile/common/values.dart';

String timeToString(int time) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(time);

  var result = "";
  if (now.year == date.year && now.month == date.month && now.day == date.day) {
    var formatter = DateFormat("HH:mm");
    result = "今日 ${formatter.format(date)}";
  } else if (now.year == date.year &&
      now.month == date.month &&
      now.day == date.day - 1) {
    var formatter = DateFormat("HH:mm");
    result = "明日 ${formatter.format(date)}";
  } else if (now.year == date.year &&
      now.month == date.month &&
      now.day == date.day + 1) {
    var formatter = DateFormat("HH:mm");
    result = "昨日 ${formatter.format(date)}";
  } else {
    var formatter = DateFormat("yyyy/MM/dd HH:mm");
    result = formatter.format(date);
  }
  return result;
}

int stringToTime(String time, {bool includeSecond = true}) {
  var formatter = DateFormat("yyyy/MM/dd HH:mm:ss");
  if (!includeSecond) {
    formatter = DateFormat("yyyy/MM/dd HH:mm");
  }
  return formatter.parse(time).millisecondsSinceEpoch;
}

Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
  return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
}

String getCurrentTerm() {
  var today = DateTime.now();
  if (3 < today.month && today.month < 9) {
    return Term.FIRST;
  } else {
    return Term.SECOND;
  }
}

// return only last one
T1? findMapKeyFromValue<T1, T2>(Map<T1, T2> map, T2 targetValue) {
  T1? resultKey;
  map.forEach((key, value) {
    if (targetValue == value) {
      resultKey = key;
    }
  });
  return resultKey;
}

String genHiddenText(String text) {
  var result = "";
  for (int i = 0; i < text.length; i++) {
    result += "•";
  }
  return result;
}

bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

Future<String> convertUrlQueryString(String queryValue,
    {String encode = "utf-8"}) async {
  var charArray = await CharsetConverter.encode(encode, queryValue);
  var queryString = "";
  charArray.forEach((element) {
    var hexChar = element.toRadixString(16).toUpperCase();
    queryString += "%$hexChar";
  });

  return queryString;
}

Future<String> convertEUCJPtoUTF8(List<int> charArray) async {
  var string = CharsetConverter.decode("EUC-JP", Uint8List.fromList(charArray));
  return string;
}
