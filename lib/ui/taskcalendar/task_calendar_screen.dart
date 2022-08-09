import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen_state.dart';

import '../scomb_mobile.dart';

class TaskCalendarScreen extends StatefulWidget {
  TaskCalendarScreen(this.parent, {Key? key}) : super(key: key);
  ScombMobileState parent;

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState(parent);
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen>
    implements NetworkScreenState {
  _TaskCalendarScreenState(this.parent);

  @override
  ScombMobileState parent;
  @override
  bool initialized = false;
  @override
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("締切カレンダー"),
      ),
      body: const Center(child: Text("カレンダー画面")),
    );
  }

  @override
  void fetchData() {
    // TODO: implement fetchData
  }

  @override
  void refreshData() {
    // TODO: implement refreshData
  }
}
