import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scomb_mobile/ui/screen/setting_screen.dart';
import 'package:scomb_mobile/ui/screen/task_calendar_screen.dart';
import 'package:scomb_mobile/ui/screen/task_list_screen.dart';
import 'package:scomb_mobile/ui/screen/timetable_screen.dart';

import 'screen/login_screen.dart';

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
    _screens.add(TimetableScreen(this, "時間割"));
    _screens.add(TaskListScreen(this, "課題・テスト一覧"));
    _screens.add(TaskCalendarScreen(this, "締切カレンダー"));
    _screens.add(SettingScreen(this));
    _screens.add(LoginScreen(this));
  }

  // bottom nav selection
  // null : login screen
  int? selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // init notification
    FlutterLocalNotificationsPlugin().initialize(
      const InitializationSettings(
        iOS: IOSInitializationSettings(),
        android: AndroidInitializationSettings("@drawable/ic_notification"),
      ),
      onSelectNotification: (_) {
        // launchUrl()
      },
    );
  }

  void navToLoginScreen() {
    setBottomNavIndex(null);
  }

  void setBottomNavIndex(int? index) {
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
}
