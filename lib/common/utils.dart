import 'dart:ui';

import 'package:intl/intl.dart';

String timeToString(int time) {
  var date = DateTime.fromMillisecondsSinceEpoch(time);
  var formatter = DateFormat("yyyy/MM/dd HH:mm");
  return formatter.format(date);
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
