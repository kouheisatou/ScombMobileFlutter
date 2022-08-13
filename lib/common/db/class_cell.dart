import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/shared_resource.dart';

import '../values.dart';

@Entity(tableName: "class_cell")
class ClassCell {
  @primaryKey
  String classId;
  String name;
  String teachers;
  String room;
  int dayOfWeek;
  int period;
  int year;
  int term;
  int? customColorInt;
  late String url;

  ClassCell(
    this.classId,
    this.name,
    this.teachers,
    this.room,
    this.dayOfWeek,
    this.period,
    this.year,
    this.term,
    this.customColorInt,
  ) {
    url = "$CLASS_PAGE_URL?idnumber=$classId";
  }

  Future<void> setColor(int? colorInt) async {
    if (colorInt == null) return;
    var db = await AppDatabase.getDatabase();
    customColorInt = colorInt;
    await db.currentClassCellDao.insertClassCell(this);

    // apply to task color
    for (var element in taskList) {
      if (element.classId == classId) {
        element.customColor = colorInt;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is ClassCell) {
      return (other.classId == classId);
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return "ClassCell { classId=$classId, name=$name, teachers=$teachers, room=$room, dayOfWeek=$dayOfWeek, period=$period, year=$year, term=$term, customColor=$customColorInt }";
  }
}
