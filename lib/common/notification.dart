import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/task.dart';

Future<void> registerTaskNotification(List<Task> tasks) async {
  var db = await AppDatabase.getDatabase();
  final plugin = FlutterLocalNotificationsPlugin();

  var notificationTimingSetting =
      await db.currentSettingDao.getSetting(SettingKeys.NOTIFICATION_TIMING);
  int notifyBefore = int.parse(
    notificationTimingSetting?.settingValue ?? (60000 * 60).toString(),
  );

  for (var task in tasks) {
    int notifyTime = task.deadline - notifyBefore;
    if (notifyTime < DateTime.now().millisecondsSinceEpoch) {
      notifyTime = DateTime.now().millisecondsSinceEpoch + 1000;
    }

    plugin.zonedSchedule(
      task.id.hashCode,
      "課題締め切り",
      "${task.title} (${timeToString(task.deadline)})",
      tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.UTC,
        notifyTime,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "SCOMB_MOBILE_TASK_NOTIFICATION",
          "課題締め切り通知",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
    print(
        "resumed_task_notification ${timeToString(notifyTime)} (${task.title})");
  }
}

void cancelNotification({int? notificationId}) {
  final plugin = FlutterLocalNotificationsPlugin();

  if (notificationId == null) {
    plugin.cancelAll();
  } else {
    plugin.cancel(notificationId);
  }
}

Future<void> registerTodaysTaskNotification(List<Task> tasks) async {
  var db = await AppDatabase.getDatabase();
  final plugin = FlutterLocalNotificationsPlugin();

  var notifyTimeSetting = (await db.currentSettingDao
              .getSetting(SettingKeys.TODAYS_TASK_NOTIFICATION_TIME))
          ?.settingValue ??
      "8:00";
  var notifyTime = TimeOfDay(
    hour: int.parse(notifyTimeSetting.split(":")[0]),
    minute: int.parse(
      notifyTimeSetting.split(":")[1],
    ),
  );

  for (var task in tasks) {
    var deadlineDate = DateTime.fromMillisecondsSinceEpoch(task.deadline);
    var resumeTime = DateTime(
      deadlineDate.year,
      deadlineDate.month,
      deadlineDate.day,
      notifyTime.hour,
      notifyTime.minute,
    );

    if (resumeTime.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      continue;
    }

    plugin.zonedSchedule(
      ("${task.id}-today").hashCode,
      "今日締め切りの課題",
      "${task.title} (${timeToString(task.deadline)})",
      tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.UTC,
        resumeTime.millisecondsSinceEpoch,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "SCOMB_MOBILE_TASK_NOTIFICATION",
          "今日締切の課題",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
    print("resumed_todays_task_notification $resumeTime (${task.title})");
  }
}
