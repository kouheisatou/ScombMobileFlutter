import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';

@dao
abstract class SettingDao {
  @Query("SELECT * FROM settings WHERE settingKey = :settingKey")
  Future<Setting?> getSetting(String settingKey);

  @Query("SELECT * FROM settingKey")
  Future<List<Setting>> getAllSetting();

  @insert
  Future<void> insertSetting(Setting setting);

  @Query("DELETE FROM settings WHERE settingKey = :settingKey")
  Future<void> deleteSetting(String settingKey);
}
