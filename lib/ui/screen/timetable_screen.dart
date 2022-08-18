import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/database_exception.dart';
import 'package:scomb_mobile/common/db/class_cell.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/scraping/timetable_scraping.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/dialog/class_detail_dialog.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/task_list_screen.dart';

import '../../common/scraping/surveys_scraping.dart';
import '../../common/scraping/task_scraping.dart';
import '../../common/shared_resource.dart';
import '../../common/values.dart';

class TimetableScreen extends NetworkScreen {
  TimetableScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  NetworkScreenState<TimetableScreen> createState() {
    return _TimetableScreenState();
  }
}

class _TimetableScreenState extends NetworkScreenState<TimetableScreen> {
  _TimetableScreenState();

  bool saturdayClassExists = true;

  Future<void> fetchAllTasks(String savedSessionId) async {
    if (taskListInitialized) return;

    // tasks from db
    inflateTasksFromDB();

    // inflate tasks from server
    fetchSurveys(sessionId ?? savedSessionId);
    fetchTasks(sessionId ?? savedSessionId);

    taskListInitialized = true;
  }

  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    fetchAllTasks(savedSessionId);

    var db = await AppDatabase.getDatabase();

    var prevTimetableYear = timetableYear;
    var prevTimetableTerm = timetableTerm;

    late int refreshInterval;
    late int lastUpdate;
    try {
      timetableYear = int.parse(
          (await db.currentSettingDao.getSetting(SettingKeys.TIMETABLE_YEAR))
                  ?.settingValue ??
              DateTime.now().year.toString());
      timetableTerm =
          (await db.currentSettingDao.getSetting(SettingKeys.TIMETABLE_TERM))
                  ?.settingValue ??
              getCurrentTerm();
      refreshInterval = int.parse((await db.currentSettingDao
                  .getSetting(SettingKeys.TIMETABLE_UPDATE_INTERVAL))
              ?.settingValue ??
          (86400000 * 7).toString());
      lastUpdate = int.parse((await db.currentSettingDao
                  .getSetting(SettingKeys.TIMETABLE_LAST_UPDATE))
              ?.settingValue ??
          "0");
    } catch (e) {
      throw DatabaseException("不正な設定");
    }

    // on timetable year or term setting changed, force fetch from server
    var forceRefresh = false;
    if ((timetableYear != prevTimetableYear ||
            timetableTerm != prevTimetableTerm) &&
        timetableInitialized) {
      forceRefresh = true;
      timetableInitialized = false;
    }
    print("start to fetch timetable ($timetableYear-$timetableTerm)");

    if (timetableInitialized) return;

    clearTimetable();

    // timetable info too old
    if (lastUpdate < DateTime.now().millisecondsSinceEpoch - refreshInterval ||
        forceRefresh) {
      // fetch timetable from server
      await fetchTimetable(
        sessionId ?? savedSessionId,
        timetableYear ?? DateTime.now().year,
        timetableTerm ?? getCurrentTerm(),
      );
      db.currentSettingDao.insertSetting(Setting(
          SettingKeys.TIMETABLE_LAST_UPDATE,
          DateTime.now().millisecondsSinceEpoch.toString()));
    } else {
      // recover from db
      var allClasses = await db.currentClassCellDao.getAllClasses();
      for (var c in allClasses) {
        if (c.year == timetableYear && c.term == timetableTerm) {
          timetable[c.period][c.dayOfWeek] = c;
        }
      }
    }

    timetableInitialized = true;
    saturdayClassExists = checkSaturdayClassExists();
  }

  @override
  Future<void> getDataOffLine() async {
    // recover timetable from db
    var db = await AppDatabase.getDatabase();
    var allClasses = await db.currentClassCellDao.getAllClasses();
    for (var c in allClasses) {
      if (c.year == timetableYear && c.term == timetableTerm) {
        timetable[c.period][c.dayOfWeek] = c;
      }
    }
  }

  @override
  Widget innerBuild() {
    return DefaultTextStyle(
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: Colors.black),
      child: buildTable(),
    );
  }

  Widget buildTable() {
    // day of week row
    List<Widget> tableRows = [buildDayOfWeekRow()];

    // main rows
    for (int r = 0; r < timetable.length; r++) {
      tableRows.add(buildTableRow(r));
    }

    return Column(
      children: tableRows,
    );
  }

  Row buildDayOfWeekRow() {
    List<Widget> dayOfWeekCells = [];
    // day of week row
    dayOfWeekCells.add(
      const Text(" 　"),
    );
    DAY_OF_WEEK_MAP.forEach(
      (key, value) {
        // skip saturday
        if (saturdayClassExists || key != 5) {
          dayOfWeekCells.add(
            Expanded(
              child: Center(
                child: Text(value),
              ),
            ),
          );
        }
      },
    );
    return Row(children: dayOfWeekCells);
  }

  Widget buildTableRow(int row) {
    List<Widget> tableCells = [];

    // period column
    tableCells.add(
      Center(
        child: Text(textAlign: TextAlign.center, PERIOD_MAP[row] ?? ""),
      ),
    );

    // main columns
    for (int c = 0; c < timetable[0].length; c++) {
      if (saturdayClassExists || c != 5) {
        tableCells.add(buildTableCell(row, c));
      }
    }

    return Expanded(child: Row(children: tableCells));
  }

  Widget buildTableCell(int row, int col) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: timetable[row][col] == null
            ? const Text("")
            : MaterialButton(
                color: Color(
                  timetable[row][col]?.customColorInt ?? Colors.white70.value,
                ),
                onPressed: () async {
                  var currentClassCell = timetable[row][col]!;
                  var detailDialog = ClassDetailDialog(currentClassCell);
                  await showDialog(
                    context: context,
                    builder: (_) {
                      return detailDialog;
                    },
                  );
                  await currentClassCell.setColor(detailDialog.selectedColor);

                  // apply color to same class
                  applyToAllCells((classCell) async {
                    if (classCell != null) {
                      if (classCell.classId == currentClassCell.classId) {
                        await classCell.setColor(detailDialog.selectedColor);
                      }
                    }
                  });

                  setState(() {});
                },
                onLongPress: () async {
                  Fluttertoast.showToast(msg: timetable[row][col]?.room ?? "");
                },
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: buildLimitedText(
                    timetable[row][col]?.name ?? "",
                    saturdayClassExists ? 3 : 4,
                  ),
                ),
              ),
      ),
    );
  }

  Text buildLimitedText(String text, int limit) {
    String newText = "";
    int count = 0;
    int returnCount = 0;
    for (var char in text.split("")) {
      if (count % limit == 0 && count != 0) {
        if (returnCount > 5) {
          newText += "..";
          break;
        } else {
          newText += "\n$char";
          returnCount++;
        }
      } else {
        newText += char;
      }
      count++;
    }

    if (newText == "") {
      return const Text("  ");
    }

    return Text(
      newText,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Future<void> applyToAllCells(
      void Function(ClassCell? classCell) process) async {
    for (int r = 0; r < timetable.length; r++) {
      for (int c = 0; c < timetable[0].length; c++) {
        process(timetable[r][c]);
      }
    }
  }

  bool checkSaturdayClassExists() {
    var result = false;
    applyToAllCells((classCell) {
      if (classCell?.dayOfWeek == 5) {
        result = true;
      }
    });
    return result;
  }

  @override
  Future<void> refreshData() async {
    super.fetchData();
    timetableInitialized = false;
  }
}
