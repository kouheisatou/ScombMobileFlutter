import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/settings/setting_screen.dart';
import 'package:scomb_mobile/ui/taskcalendar/task_calendar_screen.dart';
import 'package:scomb_mobile/ui/tasklist/task_list_screen.dart';
import 'package:scomb_mobile/ui/timetable/timetable_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() {
    return _BottomNavigationWidgetState();
  }
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
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
    return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.table_chart), label: "時間割"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "課題一覧"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: "締切カレンダー"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}
