import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/shared_resource.dart';

@Entity(tableName: "class_cell")
class ClassCell {
  String classId;
  String name;
  String teachers;
  String room;
  int dayOfWeek;
  int period;
  int year;
  String term;
  int? customColorInt;
  late String url;
  @primaryKey
  late String cellId;
  String? note;
  late int lateCount;
  late int absentCount;
  late String? syllabusUrl;
  @ignore
  List<List<ClassCell?>>? currentTimetable;

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
    this.note,
    this.lateCount,
    this.absentCount,
    this.syllabusUrl,
    this.url,
  ) {
    cellId = "$year:$term-$period:$dayOfWeek-$classId";
  }

  Future<void> setColor(int? colorInt, {bool applyToChildren = true}) async {
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

    // apply color to same class
    if (applyToChildren) {
      return await applyToAllCells(currentTimetable ?? sharedTimetable,
          (classCell) async {
        if (classCell != null) {
          if (classCell.classId == classId) {
            await classCell.setColor(customColorInt, applyToChildren: false);
          }
        }
      });
    }
  }

  Future<void> setNoteText(String text, {bool applyToChildren = true}) async {
    var db = await AppDatabase.getDatabase();
    note = text;
    await db.currentClassCellDao.insertClassCell(this);

    // apply text to same class
    if (applyToChildren) {
      await applyToAllCells(currentTimetable ?? sharedTimetable,
          (classCell) async {
        if (classCell != null) {
          if (classCell.classId == classId) {
            await classCell.setNoteText(note ?? "", applyToChildren: false);
          }
        }
      });
    }
  }

  Future<void> setCustomSyllabusUrl(String? url,
      {bool applyToChildren = true}) async {
    var db = await AppDatabase.getDatabase();
    syllabusUrl = url;
    await db.currentClassCellDao.insertClassCell(this);

    // apply text to same class
    if (applyToChildren) {
      await applyToAllCells(currentTimetable ?? sharedTimetable,
          (classCell) async {
        if (classCell != null) {
          if (classCell.classId == classId) {
            await classCell.setCustomSyllabusUrl(url, applyToChildren: false);
          }
        }
      });
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
    return "ClassCell { classId=$classId, name=$name, teachers=$teachers, room=$room, dayOfWeek=$dayOfWeek, period=$period, year=$year, term=$term, customColor=$customColorInt, absentCount=$absentCount, lateCount=$lateCount, note=$note }";
  }
}
