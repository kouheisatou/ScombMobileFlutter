import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/screen/link_list_screen.dart';
import 'package:scomb_mobile/ui/screen/news_list_screen.dart';
import 'package:scomb_mobile/ui/screen/setting_screen.dart';
import 'package:scomb_mobile/ui/screen/task_calendar_screen.dart';
import 'package:scomb_mobile/ui/screen/task_list_screen.dart';
import 'package:scomb_mobile/ui/screen/timetable/timetable_screen.dart';

import '../common/db/scomb_mobile_database.dart';
import '../common/db/setting_entity.dart';
import '../common/utils.dart';

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
    _screens.add(LinkListScreen());
    _screens.add(NewsScreen("お知らせ"));
    _screens.add(SettingScreen(this));
  }

  int selectedIndex = 0;

  @override
  void initState() {
    getThemeColor();
    super.initState();
  }

  Future<void> getThemeColor() async {
    var db = await AppDatabase.getDatabase();
    String? color =
        (await db.currentSettingDao.getSetting(SettingKeys.THEME_COLOR))
            ?.settingValue;
    if (color != null) {
      try {
        var colorInt = int.parse(color);
        themeColor = MaterialColor(colorInt, getSwatch(Color(colorInt)));
      } catch (e) {
        print(e);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: "ScombMobile",
      theme: ThemeData(
        primarySwatch: themeColor,
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
                icon: Icon(Icons.open_in_new),
                label: "リンク",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: "お知らせ",
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

  void setThemeColor(Color color) {
    setState(() {
      themeColor = MaterialColor(
        color.value,
        getSwatch(color),
      );
    });
  }
}
