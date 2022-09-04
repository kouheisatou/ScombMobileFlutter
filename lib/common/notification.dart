import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/task.dart';

Future<void> cancelNotification({int? notificationId}) async {
  final plugin = FlutterLocalNotificationsPlugin();

  if (notificationId == null) {
    await plugin.cancelAll();
  } else {
    await plugin.cancel(notificationId);
  }
}

Future<void> registerTaskNotification(Task task, {AppDatabase? db}) async {
  db ??= await AppDatabase.getDatabase();
  final plugin = FlutterLocalNotificationsPlugin();

  // -------- task deadline notification ---------
  var notificationTimingSetting =
      await db.currentSettingDao.getSetting(SettingKeys.NOTIFICATION_TIMING);
  int notifyBefore = int.parse(
    notificationTimingSetting?.settingValue ?? (60000 * 60).toString(),
  );
  int taskDeadlineNotifyTime = task.deadline - notifyBefore;
  if (taskDeadlineNotifyTime < DateTime.now().millisecondsSinceEpoch) {
    taskDeadlineNotifyTime = DateTime.now().millisecondsSinceEpoch + 1000;
  }

  plugin.zonedSchedule(
    task.id.hashCode,
    "課題締め切り",
    "${task.title} (${timeToString(task.deadline)})",
    tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      taskDeadlineNotifyTime,
    ),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        "SCOMB_MOBILE_TASK_NOTIFICATION",
        "課題締め切り通知",
        channelDescription: "締め切り時刻の近い課題を通知します",
        importance: Importance.max,
        priority: Priority.max,
      ),
      iOS: IOSNotificationDetails(),
    ),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
  );
  print(
      "resumed_task_notification ${timeToString(taskDeadlineNotifyTime)} (${task.title})");

  // -------- today's task notification ---------
  var notifyTimeSetting = (await db.currentSettingDao
              .getSetting(SettingKeys.TODAYS_TASK_NOTIFICATION_TIME))
          ?.settingValue ??
      "8:00";
  var todaysTaskNotifyTime = TimeOfDay(
    hour: int.parse(notifyTimeSetting.split(":")[0]),
    minute: int.parse(
      notifyTimeSetting.split(":")[1],
    ),
  );

  var deadlineDate = DateTime.fromMillisecondsSinceEpoch(task.deadline);
  var resumeTime = DateTime(
    deadlineDate.year,
    deadlineDate.month,
    deadlineDate.day,
    todaysTaskNotifyTime.hour,
    todaysTaskNotifyTime.minute,
  );

  if (resumeTime.millisecondsSinceEpoch <
      DateTime.now().millisecondsSinceEpoch) {
    return;
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
        "SCOMB_MOBILE_TODAYS_TASK_NOTIFICATION",
        "今日締切の課題",
        channelDescription: "今日締め切りの全ての課題を指定時刻に通知します",
        importance: Importance.max,
        priority: Priority.max,
      ),
      iOS: IOSNotificationDetails(),
    ),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
  );
  print("resumed_todays_task_notification $resumeTime (${task.title})");
}

Future<void> registerAllTaskNotification(List<Task> tasks) async {
  var db = await AppDatabase.getDatabase();
  for (var task in tasks) {
    registerTaskNotification(task, db: db);
  }
}
