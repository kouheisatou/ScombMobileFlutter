import 'dart:async';
import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/class_cell_dao.dart';
import 'package:scomb_mobile/common/db/my_link_dao.dart';
import 'package:scomb_mobile/common/db/my_link_entity.dart';
import 'package:scomb_mobile/common/db/news_item_model_dao.dart';
import 'package:scomb_mobile/common/db/news_item_model_entity.dart';
import 'package:scomb_mobile/common/db/setting_dao.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/db/task.dart';
import 'package:scomb_mobile/common/db/task_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'class_cell.dart';

part 'scomb_mobile_database.g.dart';

@Database(
    version: 6, entities: [Setting, ClassCell, Task, MyLink, NewsItemModel])
abstract class AppDatabase extends FloorDatabase {
  static AppDatabase? _appDatabase;

  SettingDao get currentSettingDao;

  ClassCellDao get currentClassCellDao;

  TaskDao get currentTaskDao;

  MyLinkDao get currentMyLinkDao;

  NewsItemModelDao get currentNewsItemModelDao;

  static Future<AppDatabase> getDatabase() async {
    return _appDatabase ??= await $FloorAppDatabase
        .databaseBuilder('scomb_mobile.db')
        .addMigrations([
      migration1to2,
      migration2to3,
      migration3to4,
      migration4to5,
      migration5to6,
    ]).build();
  }

  Future<String> exportToJson() async {
    var allClasses = await currentClassCellDao.getAllClasses();
    var allMyLinks = await currentMyLinkDao.getAllLinks();
    var allNewsItems = await currentNewsItemModelDao.getAllNews();
    var allSettings = await currentSettingDao.getAllSetting();
    var allTasks = await currentTaskDao.getAllTasks();
    return json.encode({
      "class_cell": allClasses,
      "settings": allSettings,
      "task": allTasks,
      "my_links": allMyLinks,
      "news_item": allNewsItems,
    });
  }
}

final migration1to2 = Migration(1, 2, (database) {
  return database.execute("ALTER TABLE class_cell ADD COLUMN syllabusUrl TEXT");
});

// class_cell primary key change
final migration2to3 = Migration(2, 3, (database) async {
  await database.rawQuery("DROP TABLE class_cell;");
  await database.rawQuery(
      "CREATE TABLE class_cell(classId TEXT NOT NULL, period INTEGER NOT NULL, dayOfWeek INTEGER NOT NULL, isUserClassCell INTEGER NOT NULL, timetableTitle TEXT NOT NULL, year INTEGER, term TEXT, name TEXT, teachers TEXT, room TEXT, customColorInt INTEGER, url TEXT, note TEXT, syllabusUrl TEXT, PRIMARY KEY (classId, period, dayOfWeek, isUserClassCell, timetableTitle));");
  await database.rawQuery(
      "INSERT OR REPLACE INTO settings (settingKey, settingValue) values ('${SettingKeys.TIMETABLE_LAST_UPDATE}', '0');");
});

// class_cell primary key change
final migration3to4 = Migration(3, 4, (database) async {
  await database
      .rawQuery("ALTER TABLE class_cell ADD COLUMN numberOfCredit INT;");
});

// add my_links table
final migration4to5 = Migration(4, 5, (database) async {
  await database.rawQuery(
      "CREATE TABLE `my_links` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `url` TEXT NOT NULL);");
});

// add news_item table
final migration5to6 = Migration(5, 6, (database) async {
  await database.rawQuery(
      "CREATE TABLE IF NOT EXISTS `news_item` (`newsId` TEXT NOT NULL, `data2` TEXT NOT NULL, `title` TEXT NOT NULL, `category` TEXT NOT NULL, `domain` TEXT NOT NULL, `publishTime` TEXT NOT NULL, `tags` TEXT NOT NULL, `unread` INTEGER NOT NULL, PRIMARY KEY (`newsId`))");
});
