import 'package:floor/floor.dart';

import '../values.dart';

@Entity(tableName: "settings")
class Setting {
  Setting(this.settingKey, this.settingValue);

  @primaryKey
  String settingKey;

  String? settingValue;

  @override
  bool operator ==(Object other) {
    if (other is Setting) {
      return (other.settingValue == settingValue &&
          other.settingKey == settingKey);
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return "Setting($settingKey=$settingValue)";
  }
}

class SettingKeys {
  static String USERNAME = "username";
  static String PASSWORD = "password";
  static String SESSION_ID = "session_id";
  static String ENABLED_AUTO_LOGIN = "enabled_auto_login";

  static String TIMETABLE_LAST_UPDATE = "timetable_last_update";
  static String TIMETABLE_UPDATE_INTERVAL = "timetable_update_interval";
  static String TIMETABLE_YEAR = "timetable_year";
  static String TIMETABLE_TERM = "timetable_term";

  static String NOTIFICATION_TIMING = "notification_timing";
  static String TODAYS_TASK_NOTIFICATION_TIME = "todays_task_notification_time";
}

class SettingValues {
  static Map<String, int> TIMETABLE_UPDATE_INTERVAL = {
    "1日": 86400000 * 1,
    "2日": 86400000 * 2,
    "1週間": 86400000 * 7,
    "2週間": 86400000 * 14,
    "4週間": 86400000 * 28,
  };

  static Map<String, String> TIMETABLE_TERM = {
    "前期": Term.FIRST,
    "後期": Term.SECOND,
  };

  static Map<String, int> NOTIFICATION_TIMING = {
    "10分前": 60000 * 10,
    "30分前": 60000 * 30,
    "1時間前": 60000 * 60,
    "2時間前": 60000 * 60 * 2,
    "3時間前": 60000 * 60 * 3,
    "6時間前": 60000 * 60 * 6,
    "1日前": 60000 * 60 * 24,
  };
}
