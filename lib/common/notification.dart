import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db/task.dart';

Future<void> registerTaskNotification(Task task) async {
  final plugin = FlutterLocalNotificationsPlugin();

  print(timeToString(task.deadline));

  return plugin.zonedSchedule(
    task.id.hashCode,
    "課題締め切り通知",
    "${task.title} (${timeToString(task.deadline)})",
    tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      task.deadline,
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
