import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen_state.dart';

import '../scomb_mobile.dart';

class TaskCalendarScreen extends StatefulWidget {
  TaskCalendarScreen(this.parent, {Key? key}) : super(key: key);
  ScombMobileState parent;

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState(
        parent,
        "締切カレンダー",
      );
}

class _TaskCalendarScreenState extends NetworkScreenState<TaskCalendarScreen> {
  _TaskCalendarScreenState(super.parent, super.title);

  @override
  void fetchData() {
    // TODO: implement fetchData
  }

  @override
  void refreshData() {
    // TODO: implement refreshData
  }

  @override
  Widget innerBuild() {
    return const Center(child: Text("カレンダー画面"));
  }
}
