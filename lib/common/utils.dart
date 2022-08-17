import 'dart:ui';

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
T? findMapKeyFromValue<T>(Map<String, T> map, String targetKey) {
  T? result;
  map.forEach((key, value) {
    if (targetKey == key) {
      result = value;
    }
  });

  return result;
}
