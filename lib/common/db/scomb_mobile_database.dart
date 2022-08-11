import 'dart:async';

import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/class_cell_dao.dart';
import 'package:scomb_mobile/common/db/setting_dao.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'class_cell.dart';

part 'scomb_mobile_database.g.dart';

@Database(version: 1, entities: [Setting, ClassCell])
abstract class AppDatabase extends FloorDatabase {
  static AppDatabase? _appDatabase;

  SettingDao get currentSettingDao;
  ClassCellDao get currentClassCellDao;

  static Future<AppDatabase> getDatabase() async {
    return _appDatabase ??=
        await $FloorAppDatabase.databaseBuilder('scomb_mobile.db').build();
  }
}
