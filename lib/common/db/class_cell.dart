import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/dialog/class_detail_dialog.dart';

import '../../ui/dialog/color_picker_dialog.dart';
import '../timetable_model.dart';

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
  TimetableModel? currentTimetable;

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
    resetCellId();
  }

  void resetCellId() {
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
      return await (currentTimetable ?? sharedTimetable)
          .applyToAllCells((classCell) async {
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
      await (currentTimetable ?? sharedTimetable)
          .applyToAllCells((classCell) async {
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
      await (currentTimetable ?? sharedTimetable)
          .applyToAllCells((classCell) async {
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

  Future<void> showClassDetailDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) {
        return ClassDetailDialog(this);
      },
    );
  }

  Future<void> showColorPickerDialog(BuildContext context) async {
    int? selectedColor = await showDialog<int>(
      context: context,
      builder: (builder) {
        return ColorPickerDialog();
      },
    );

    await setColor(selectedColor);
  }

  Future<void> showNoteEditDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("メモ"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("閉じる"),
            )
          ],
          content: TextFormField(
            autofocus: true,
            initialValue: note,
            maxLines: null,
            onChanged: (text) async {
              setNoteText(text);
            },
          ),
        );
      },
    );
  }

  Future<void> showRemoveClassDialog(BuildContext context) async {
    var timetable = currentTimetable ?? sharedTimetable;
    var db = await AppDatabase.getDatabase();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("削除"),
          content: const Text("本当に削除しますか？"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("キャンセル")),
            TextButton(
                onPressed: () async {
                  await timetable.removeCell(this, db);
                  Navigator.pop(context);
                },
                child: const Text("削除")),
          ],
        );
      },
    );
  }
}
