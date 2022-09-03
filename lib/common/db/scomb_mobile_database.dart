import 'dart:async';

import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/class_cell_dao.dart';
import 'package:scomb_mobile/common/db/setting_dao.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/db/task.dart';
import 'package:scomb_mobile/common/db/task_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'class_cell.dart';

part 'scomb_mobile_database.g.dart';

@Database(version: 2, entities: [Setting, ClassCell, Task])
abstract class AppDatabase extends FloorDatabase {
  static AppDatabase? _appDatabase;

  SettingDao get currentSettingDao;

  ClassCellDao get currentClassCellDao;

  TaskDao get currentTaskDao;

  static Future<AppDatabase> getDatabase() async {
    return _appDatabase ??= await $FloorAppDatabase
        .databaseBuilder('scomb_mobile.db')
        .addMigrations([migration1to2]).build();
  }
}

final migration1to2 = Migration(1, 2, (database) {
  print("migration_1_to_2");
  return database.execute("ALTER TABLE class_cell ADD COLUMN syllabusUrl TEXT");
});
