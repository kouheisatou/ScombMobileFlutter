import 'package:floor/floor.dart';

@Entity(tableName: "settings")
class Setting {
  Setting(this.settingKey, this.settingValue);

  @primaryKey
  final String settingKey;

  final String settingValue;

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
}
