import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

void main() {
  runApp(const ScombMobile());
  // runApp(TestApp());
  initNotification();
}

Future<void> initNotification() async {
  // init notification
  var plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      iOS: IOSInitializationSettings(),
      android: AndroidInitializationSettings("@drawable/ic_notification"),
    ),
    onSelectNotification: (_) {
      // launchUrl()
    },
  );

  if (Platform.isAndroid) {
    const AndroidNotificationChannel todaysTaskChannel =
        AndroidNotificationChannel(
      "SCOMB_MOBILE_TODAYS_TASK_NOTIFICATION",
      "今日締切の課題",
      description: "今日締め切りの全ての課題を指定時刻に通知します",
      importance: Importance.max,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(todaysTaskChannel);

    const AndroidNotificationChannel taskChannel = AndroidNotificationChannel(
      "SCOMB_MOBILE_TASK_NOTIFICATION",
      "課題締め切り通知",
      description: "締め切り時刻の近い課題を通知します",
      importance: Importance.max,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(taskChannel);
  }
}
