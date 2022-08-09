import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/timetable_scraping.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/settings/setting_screen.dart';
import 'package:scomb_mobile/ui/taskcalendar/task_calendar_screen.dart';
import 'package:scomb_mobile/ui/tasklist/task_list_screen.dart';
import 'package:scomb_mobile/ui/timetable/timetable_screen.dart';

import 'login/login_screen.dart';

class ScombMobile extends StatefulWidget {
  const ScombMobile({Key? key}) : super(key: key);

  @override
  State<ScombMobile> createState() {
    return ScombMobileState();
  }
}

class ScombMobileState extends State<ScombMobile> {
  final List<StatelessWidget> _screens = [];
  ScombMobileState() {
    _screens.add(const TimetableScreen());
    _screens.add(const TaskListScreen());
    _screens.add(const TaskCalendarScreen());
    _screens.add(const SettingScreen());
    _screens.add(LoginScreen(this));

    fetchData();
  }

  // bottom nav selection
  // null : login screen
  int? selectedIndex = 0;

  void setIndex(int? index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ScombMobile",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        // if selected index null, attach login screen
        body: _screens[selectedIndex ?? 4],
        // if login screen, disable bottom nav
        bottomNavigationBar: selectedIndex != null
            ? BottomNavigationBar(
                // set bottom selection last
                currentIndex: selectedIndex ?? 0,
                onTap: setIndex,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.table_chart),
                    label: "時間割",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: "課題一覧",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: "カレンダー",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: "設定",
                  ),
                ],
                type: BottomNavigationBarType.fixed,
              )
            : null,
      ),
    );
  }

  Future<void> fetchData() async {
    // todo recover from local db
    var savedSessionId = "";
    var yearFromSettings = 2022;
    var termFromSettings = Term.FIRST;

    timetable = await fetchTimetable(
      sessionId ?? savedSessionId,
      yearFromSettings,
      termFromSettings,
    );

    // permission error
    if (timetable == null) {
      setState(() {
        selectedIndex = null;
      });
    }
  }
}
