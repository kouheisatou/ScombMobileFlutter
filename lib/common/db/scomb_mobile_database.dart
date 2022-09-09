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

@Database(version: 3, entities: [Setting, ClassCell, Task])
abstract class AppDatabase extends FloorDatabase {
  static AppDatabase? _appDatabase;

  SettingDao get currentSettingDao;

  ClassCellDao get currentClassCellDao;

  TaskDao get currentTaskDao;

  static Future<AppDatabase> getDatabase() async {
    return _appDatabase ??= await $FloorAppDatabase
        .databaseBuilder('scomb_mobile.db')
        .addMigrations([migration1to2, migration1to3, migration2to3]).build();
  }
}

final migration1to2 = Migration(1, 2, (database) {
  print("migration_1_to_2");
  return database.execute("ALTER TABLE class_cell ADD COLUMN syllabusUrl TEXT");
});

final migration1to3 = Migration(1, 3, (database) async {
  print("migration_1_to_3");
  await migrationTo3(database);
});

final migration2to3 = Migration(2, 3, (database) async {
  print("migration_2_to_3");
  await migrationTo3(database);
});

// class_cell primary key change
Future<void> migrationTo3(sqflite.Database database) async {
  await database.rawQuery("DROP TABLE class_cell;");
  await database.rawQuery(
      "CREATE TABLE class_cell(classId TEXT NOT NULL, period INTEGER NOT NULL, dayOfWeek INTEGER NOT NULL, isUserClassCell INTEGER NOT NULL, timetableTitle TEXT NOT NULL, year INTEGER, term TEXT, name TEXT, teachers TEXT, room TEXT, customColorInt INTEGER, url TEXT, note TEXT, syllabusUrl TEXT, PRIMARY KEY (classId, period, dayOfWeek, isUserClassCell, timetableTitle));");
  await database.rawQuery(
      "INSERT OR REPLACE INTO settings (settingKey, settingValue) values ('${SettingKeys.TIMETABLE_LAST_UPDATE}', '0');");
}
