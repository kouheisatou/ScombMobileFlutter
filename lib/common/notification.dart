import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/task.dart';

Future<void> registerTaskNotification(Task task) async {
  var db = await AppDatabase.getDatabase();
  var notificationTimingSetting =
      await db.currentSettingDao.getSetting(SettingKeys.NOTIFICATION_TIMING);
  int notifyBefore = int.parse(
    notificationTimingSetting?.settingValue ?? (60000 * 60).toString(),
  );

  int notifyTime = task.deadline - notifyBefore;
  if (notifyTime < DateTime.now().millisecondsSinceEpoch) {
    notifyTime = DateTime.now().millisecondsSinceEpoch + 1000;
  }

  final plugin = FlutterLocalNotificationsPlugin();
  return plugin.zonedSchedule(
    task.id.hashCode,
    "課題締め切り通知",
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
}

Future<void> cancelNotification() async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.cancelAll();
}
