import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/database_exception.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/scraping/timetable_scraping.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/component/timetable_component.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';

import '../../../common/shared_resource.dart';
import '../../../common/values.dart';
import 'my_timetable_list_screen.dart';

class TimetableScreen extends NetworkScreen {
  TimetableScreen(super.title, {Key? key}) : super(key: key);

  @override
  NetworkScreenState<TimetableScreen> createState() {
    return _TimetableScreenState();
  }
}

class _TimetableScreenState extends NetworkScreenState<TimetableScreen> {
  _TimetableScreenState();

  bool saturdayClassExists = true;

  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    // fetchAllTasks(savedSessionId);

    var db = await AppDatabase.getDatabase();

    // inflate last update settings
    var prevTimetableYear = timetableYear;
    var prevTimetableTerm = timetableTerm;
    late int refreshInterval;
    late int lastUpdate;
    try {
      timetableYear = int.parse(
          (await db.currentSettingDao.getSetting(SettingKeys.TIMETABLE_YEAR))
                  ?.settingValue ??
              getCurrentYear().toString());
      timetableTerm =
          (await db.currentSettingDao.getSetting(SettingKeys.TIMETABLE_TERM))
                  ?.settingValue ??
              getCurrentTerm();
      refreshInterval = int.parse((await db.currentSettingDao
                  .getSetting(SettingKeys.TIMETABLE_UPDATE_INTERVAL))
              ?.settingValue ??
          (86400000 * 1).toString());
      lastUpdate = int.parse((await db.currentSettingDao
                  .getSetting(SettingKeys.TIMETABLE_LAST_UPDATE))
              ?.settingValue ??
          "0");
    } catch (e) {
      throw DatabaseException("不正な設定");
    }
    widget.title = "$timetableYear年度 ${TERM_DISP_NAME_MAP[timetableTerm]} 時間割";

    // on timetable year or term setting changed, force fetch from server
    var forceRefresh = false;
    if ((timetableYear != prevTimetableYear ||
            timetableTerm != prevTimetableTerm) &&
        timetableInitialized) {
      forceRefresh = true;
      timetableInitialized = false;
    }
    print("start to fetch timetable ($timetableYear-$timetableTerm)");

    saturdayClassExists = checkSaturdayClassExists();

    if (timetableInitialized) return;

    sharedTimetable.clearTimetable();

    // timetable info too old
    if (lastUpdate < DateTime.now().millisecondsSinceEpoch - refreshInterval ||
        forceRefresh) {
      // fetch timetable from server
      await fetchTimetable(
        sessionId ?? savedSessionId,
        timetableYear ?? getCurrentYear(),
        timetableTerm ?? getCurrentTerm(),
      );

      // last update time
      db.currentSettingDao.insertSetting(
        Setting(
          SettingKeys.TIMETABLE_LAST_UPDATE,
          DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
    } else {
      // get from db
      var allClasses = await db.currentClassCellDao
          .getCells("$timetableYear-$timetableTerm");
      for (var c in allClasses) {
        if (c.year == timetableYear &&
            c.term == timetableTerm &&
            !c.isUserClassCell) {
          sharedTimetable.cells[c.period][c.dayOfWeek] = c;
          print(c);
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
        sharedTimetable.cells[c.period][c.dayOfWeek] = c;
      }
    }
  }

  @override
  Widget innerBuild() {
    return TimetableComponent(
      sharedTimetable,
      checkSaturdayClassExists(),
      isEditMode: false,
    );
  }

  bool checkSaturdayClassExists() {
    var result = false;
    sharedTimetable.applyToAllCells((classCell) {
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

  @override
  List<Widget> buildAppBarActions() {
    List<Widget> result = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkResponse(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (builder) {
              return MyTimetableListScreen();
            }));
          },
          child: Column(
            children: const [
              Icon(Icons.list),
              Text(
                "履修計画",
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    ];
    return result;
  }
}
