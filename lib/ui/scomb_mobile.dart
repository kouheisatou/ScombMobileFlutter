import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/screen/class_search_screen.dart';
import 'package:scomb_mobile/ui/screen/setting_screen.dart';
import 'package:scomb_mobile/ui/screen/task_calendar_screen.dart';
import 'package:scomb_mobile/ui/screen/task_list_screen.dart';
import 'package:scomb_mobile/ui/screen/timetable/timetable_screen.dart';

class ScombMobile extends StatefulWidget {
  const ScombMobile({Key? key}) : super(key: key);

  @override
  State<ScombMobile> createState() {
    return ScombMobileState();
  }
}

class ScombMobileState extends State<ScombMobile> {
  final List<StatefulWidget> _screens = [];

  ScombMobileState() {
    _screens.add(TimetableScreen("時間割"));
    _screens.add(TaskListScreen("課題・テスト一覧"));
    _screens.add(TaskCalendarScreen("締切カレンダー"));
    _screens.add(ClassSearchScreen());
    _screens.add(SettingScreen(this));
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ScombMobile",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
          // if selected index null, attach login screen
          body: _screens[selectedIndex],
          // if login screen, disable bottom nav
          bottomNavigationBar: BottomNavigationBar(
            // set bottom selection last
            currentIndex: selectedIndex,
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
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
                icon: Icon(Icons.search),
                label: "授業検索",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "設定",
              ),
            ],
            type: BottomNavigationBarType.fixed,
          )),
    );
  }
}
