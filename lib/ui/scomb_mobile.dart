import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/settings/setting_screen.dart';
import 'package:scomb_mobile/ui/taskcalendar/task_calendar_screen.dart';
import 'package:scomb_mobile/ui/tasklist/task_list_screen.dart';
import 'package:scomb_mobile/ui/timetable/timetable_screen.dart';

class ScombMobile extends StatefulWidget {
  const ScombMobile({Key? key}) : super(key: key);

  @override
  State<ScombMobile> createState() {
    return _ScombMobileState();
  }
}

class _ScombMobileState extends State<ScombMobile> {
  static const _screens = [
    TimetableScreen(),
    TaskListScreen(),
    TaskCalendarScreen(),
    SettingScreen()
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.table_chart), label: "時間割"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "課題一覧"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: "カレンダー"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
