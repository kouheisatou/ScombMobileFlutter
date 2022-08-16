import 'package:floor/floor.dart';

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
}
